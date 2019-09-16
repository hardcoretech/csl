# frozen_string_literal: true

shared_context "a working Mock model class" do
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
      self.import_rate = "Weekly"
    end
    class MockData
    end
  end
end

describe Indexable do
  after { Object.send(:remove_const, :Mock) }

  describe ".prepare_record" do
    context "given a record with _updated_at settings" do
      include_context "a working Mock model class"
      let(:now) { Time.now.utc.iso8601(8) }

      let(:record) do
        { foo: "bar",
          yin: "yang",
          _updated_at: now,
          id: 1337, }
      end
      subject { Mock.send(:prepare_record, record) }

      it do
        is_expected.to match(foo: "bar", yin: "yang", _updated_at: now, id: 1337)
      end
    end
  end

  describe ".purge_old" do
    include_context "a working Mock model class"
    before do
      Mock.recreate_index
      Mock.index(docs_to_index)
    end

    let(:docs_to_index) do
      [{ title: "foo", _updated_at: 2.days.ago },
       { title: "bar" },]
    end

    let(:repository) { CslRepository.new(index_name: Mock.index_name) }

    context "with date arg earlier than oldest doc" do
      before { Mock.purge_old(3.days.ago) }
      it "does not purge any documents" do
        expect(repository.count).to eq 2
      end
    end

    context "with date arg between the two docs' timestamps" do
      before { Mock.purge_old(1.day.ago) }
      it "purges only the oldest doc" do
        expect(repository.count).to eq 1
      end
    end

    context "with date arg later than newest doc" do
      before { Mock.purge_old(1.second.from_now) }
      it "purges all documents" do
        expect(repository.count).to eq 0
      end
    end
  end

  describe ".importer_class" do
    include_context "a working Mock model class"
    subject { Mock.importer_class }
    it { is_expected.to eq(MockData) }
  end

  describe ".recreate_index" do
    include_context "a working Mock model class"
    before { Mock.recreate_index }

    it "sets Metadata" do
      m = metadata_repository.find Mock.index_name
      expect(m.import_rate).to eq("Weekly")
      expect(m.source).to eq("Mock")
      expect(m.source_last_updated).to be_nil
      expect(m.last_imported).to be_nil
    end
  end
end
