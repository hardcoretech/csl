# frozen_string_literal: true

module Indexable
  extend ActiveSupport::Concern

  # We include Searchable as a dependency, which provides the ability to search
  # for docs via the index defined by is module.
  include Searchable
  include Trackable

  included do
    class << self
      attr_accessor :mappings, :settings, :source, :import_rate
    end

    # If the model class doesn't define the source full_name,
    # default to the class name. This gets used when reporting
    # which sources were used in a search and when was that
    # source last updated.
    self.source = { full_name: name, code: name }
  end

  module ClassMethods
    def repository
      @repository ||= CslRepository.new(index_name: index_name)
    end

    def index_name
      @index_name ||= name.demodulize.downcase
    end

    def index(records)
      records.each { |record| repository.save(prepare_record(record)) }
      repository.refresh_index!

      Rails.logger.info "Imported #{records.size} entries to index #{index_name}"
    end

    def purge_old(before_time)
      body = Utils.older_than(before_time)
      repository.client.delete_by_query(index: repository.index_name, body: body, refresh: true)
    end

    def recreate_index
      metadata_repository.delete index_name if metadata_repository.exists? index_name
      repository.create_index! force: true
      find_or_create_metadata
    end

    def importer_class
      "#{name}Data".constantize
    end

    private
      def prepare_record(record)
        record.reverse_merge(_updated_at: Time.now.utc.iso8601(8))
      end
  end
end
