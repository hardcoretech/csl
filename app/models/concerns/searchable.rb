# frozen_string_literal: true

# See also: the Indexable concern.
#
# Searchable provides the ability to search over a set of indexes. Indexable
# provides the ability to index documents into an ES index. It is possible to
# have a module that can perform searches but cannot index documents. A
# specific example is the case where the model represents a consolidated
# endpoint. In such a case, you must set the model_classes attribute, so that
# Searchable can use those models to figure out which indexes it should perform
# the search against.

module Searchable
  extend ActiveSupport::Concern

  included do
    class << self
      attr_accessor :model_classes
      attr_accessor :fetch_all_sort_by
    end

    # Defaults to itself. This makes sense when the model is also Indexable,
    # as we're only dealing with a single source. model_classes will get
    # manually set in a non-Indexable (i.e. consolidated) model.
    self.model_classes = [self]
  end

  module ClassMethods
    def search_for(options)
      query = query_class.new(options)
      search_options = build_search_options(query)
      results = CslRepository.new.client.search(search_options)

      hits = results["hits"]
      hits[:aggregations] = results["aggregations"]
      hits[:offset] = query.offset
      hits[:sources_used] = index_meta(query.try(:sources))
      hits[:search_performed_at] = search_performed_at
      hits.deep_symbolize_keys
    end

    def query_class
      if name.split("::").last == "Consolidated"
        name.sub("Consolidated", "Query").constantize
      else
        "#{name}Query".constantize
      end
    end

    def fetch_all(sources = nil)
      search_options = { scroll: "5m", index: index_names, track_total_hits: true }
      search_options[:sort] = fetch_all_sort_by if fetch_all_sort_by

      client = CslRepository.new.client
      response = client.search(search_options)
      results = { offset: 0,
                  sources_used: index_meta(sources),
                  search_performed_at: search_performed_at,
                  hits: response["hits"].deep_symbolize_keys[:hits],
                  total: response["hits"]["total"], }

      while (response = client.scroll(scroll_id: response["_scroll_id"], scroll: "5m"))
        batch = response["hits"].deep_symbolize_keys
        break if batch[:hits].empty?
        results[:hits].concat(batch[:hits])
      end

      results
    end

    def index_names(sources = nil)
      models(sources).map(&:index_name)
    end

    def index_meta(sources = nil)
      searchable_models = models sources
      metadata_repository = MetadataRepository.new
      metadata_repository.find(searchable_models.map(&:index_name)).map do |metadata|
        metadata.to_hash(only: %i(source source_last_updated last_imported import_rate))
      end
    end

    private
      def search_performed_at
        DateTime.now.utc
      end

      def models(sources)
        models = model_classes
        if sources.try(:any?)
          selected_models = models.select { |c| sources.include?(c.source[:code]) }

          # If the given sources do not match any models, we'll search over them
          # all. This prevents us from querying EVERY index in our DB, which is
          # undesirable. It would be better if we didn't send a query to ES in this
          # case.
          models = selected_models if selected_models.any?
        end
        models
      end

      def build_search_options(query)
        {
          index: index_names(query.try(:sources)),
          body: query.generate_search_body,
          from: query.offset,
          size: query.size,
          sort: query.sort,
        }
      end
  end
end
