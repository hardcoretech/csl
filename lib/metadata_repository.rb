# frozen_string_literal: true

class MetadataRepository < BaseRepository
  klass Metadata

  settings number_of_shards: 1 do
    mapping dynamic: "strict" do
      indexes :id
      indexes :source
      indexes :source_last_updated, type: :date
      indexes :last_imported, type: :date
      indexes :version
      indexes :import_rate
    end
  end

  index_name Metadata.name.indexize
end
