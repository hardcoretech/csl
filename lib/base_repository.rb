# frozen_string_literal: true

class BaseRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  client Elasticsearch::Client.new url: ENV["ELASTICSEARCH_URL"] || "localhost:9200", log: Rails.env == "development"
end
