# frozen_string_literal: true

describe VersionableResource do
  let(:metadata_repository) { MetadataRepository.new }

  before do
    class Mock
      include Indexable
      self.mappings = {
        name.typeize => {
          properties: {
            _updated_at: { type: "date", format: "strictDateOptionalTime" },
          },
        },
      }
    end

    class MockData
      include Importable
      include VersionableResource

      def initialize(docs = nil)
        @docs = docs
      end

      def available_version
        Digest::SHA1.hexdigest(@docs.to_yaml)
      end

      def import
        model_class.index(@docs)
      end
    end

    metadata_repository.delete Mock.index_name, { ignore: 404 }
    Mock.recreate_index
  end

  after do
    Object.send(:remove_const, :Mock)
    Object.send(:remove_const, :MockData)
  end

  describe "#import" do
    it "stores the time of import" do
      MockData.new([{ id: 1, content: "foo" }]).import
      metadata = metadata_repository.find Mock.index_name
      expect(metadata.source_last_updated).to_not be_nil
      expect(metadata.last_imported).to_not be_nil
    end

    context "when source is unchanged" do
      before do
        MockData.new([{ id: 1, content: "foo" }]).import
        metadata = metadata_repository.find Mock.index_name
        Mock.update_metadata(metadata.version, DateTime.parse("2000-01-01"))
        MockData.new([{ id: 1, content: "foo" }]).import
      end
      it "updates only the time of import when source is unchanged" do
        metadata = metadata_repository.find(Mock.index_name)
        expect(metadata.source_last_updated).to eq("2000-01-01T00:00:00.000+00:00")
        expect(metadata.version).to eq("29cb2c0fe72b5d841236ddf88e22371a58649717")
        expect(metadata.last_imported).to_not eq("2000-01-01T00:00:00.000+00:00")
      end
    end

    describe "resource-versioning logic" do
      it "re-indexes different data" do
        expect(Mock).to receive(:index).twice
        MockData.new([{ id: 1, content: "foo" }]).import
        MockData.new([{ id: 2, content: "bar" }]).import
      end

      it "re-indexes identical data" do
        expect(Mock).to receive(:index).once
        MockData.new([{ id: 1, content: "foo" }]).import
        MockData.new([{ id: 1, content: "foo" }]).import
      end
    end
  end
end
