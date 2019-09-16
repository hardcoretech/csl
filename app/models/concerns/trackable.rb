# frozen_string_literal: true

module Trackable
  extend ActiveSupport::Concern

  module ClassMethods
    def metadata_repository
      MetadataRepository.new
    end

    def find_or_create_metadata
      if metadata_repository.exists? index_name
        metadata_repository.find index_name
      else
        metadata = Metadata.new id: index_name,
                                import_rate: import_rate,
                                source: source[:full_name] || source[:code]
        metadata_repository.save metadata, refresh: true
        metadata
      end
    end

    def update_metadata(version, time = DateTime.now.utc)
      metadata = find_or_create_metadata
      metadata_repository.update id: metadata.id,
                        import_rate: import_rate,
                        source: source[:full_name] || source[:code],
                        source_last_updated: time,
                        last_imported: time,
                        version: version
      metadata_repository.refresh_index!
    end

    def touch_metadata(time = DateTime.now.utc)
      metadata = find_or_create_metadata
      metadata_repository.update id: metadata.id,
                        import_rate: import_rate,
                        source: source[:full_name] || source[:code],
                        last_imported: time
      metadata_repository.refresh_index!
    end
  end
end
