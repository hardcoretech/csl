# frozen_string_literal: true

class CslRepository < BaseRepository
  settings File.open(Rails.root.join("app", "models", "settings.json")) do
    mapping do
      indexes :name,
              type: "text",
              term_vector: "with_positions_offsets",
              analyzer: "standard_asciifolding_nostop",
              fields: {
                keyword: {
                  type: "keyword"
                }
              }
      indexes :name_idx,
              type: "text",
              term_vector: "with_positions_offsets",
              analyzer: "standard_asciifolding_nostop",
              fields: {
                keyword: {
                  type: "text",
                  analyzer: "keyword_asciifolding_lowercase"
                }
              }
      indexes :alt_names,
              type: "text",
              term_vector: "with_positions_offsets",
              analyzer: "standard_asciifolding_nostop",
              fields: {
                keyword: {
                  type: "text",
                  analyzer: "keyword_asciifolding_lowercase"
                }
              }
      indexes :alt_idx,
              type: "text",
              term_vector: "with_positions_offsets",
              analyzer: "standard_asciifolding_nostop",
              fields: {
                keyword: {
                  type: "text",
                  analyzer: "keyword_asciifolding_lowercase"
                }
              }
      indexes :name_rev,
              type: "text",
              term_vector: "with_positions_offsets",
              analyzer: "standard_asciifolding_nostop",
              fields: {
                keyword: {
                  type: "text",
                  analyzer: "keyword_asciifolding_lowercase"
                }
              }
      indexes :alt_rev,
              type: "text",
              term_vector: "with_positions_offsets",
              analyzer: "standard_asciifolding_nostop",
              fields: {
                keyword: {
                  type: "text",
                  analyzer: "keyword_asciifolding_lowercase"
                }
              }
      indexes :name_no_ws,
              type: "text",
              analyzer: "standard_asciifolding_nostop",
              term_vector: "with_positions_offsets"
      indexes :name_no_ws_with_common,
              type: "text",
              analyzer: "standard_asciifolding_nostop",
              term_vector: "with_positions_offsets"
      indexes :alt_no_ws,
              type: "text",
              analyzer: "standard_asciifolding_nostop",
              term_vector: "with_positions_offsets"
      indexes :alt_no_ws_with_common,
              type: "text",
              analyzer: "standard_asciifolding_nostop",
              term_vector: "with_positions_offsets"
      indexes :name_no_ws_rev,
              type: "text",
              analyzer: "standard_asciifolding_nostop",
              term_vector: "with_positions_offsets"
      indexes :name_no_ws_rev_with_common,
              type: "text",
              analyzer: "standard_asciifolding_nostop",
              term_vector: "with_positions_offsets"
      indexes :alt_no_ws_rev,
              type: "text",
              analyzer: "standard_asciifolding_nostop",
              term_vector: "with_positions_offsets"
      indexes :alt_no_ws_rev_with_common,
              type: "text",
              analyzer: "standard_asciifolding_nostop",
              term_vector: "with_positions_offsets"
      indexes :remarks,
              type: "text",
              analyzer: "snowball_asciifolding_nostop"
      indexes :title,
              type: "text",
              analyzer: "snowball_asciifolding_nostop"
      indexes :type,
              type: "text",
              analyzer: "keyword_asciifolding_lowercase"
      indexes :source,
              type: "object",
              properties: {
                full_name: {
                  type: "text",
                  index: false
                },
                code: {
                  type: "keyword"
                }
              }
      indexes :federal_register_notice,
              type: "keyword"
      indexes :addresses,
              type: "object",
              properties: {
                country: {
                  type: "text",
                  analyzer: "keyword_asciifolding_uppercase"
                }
              }
      indexes :ids,
              type: "object",
              properties: {
                country: {
                  type: "keyword"
                },
                issue_date: {
                  type: "date",
                  format: "yyyy-MM-dd"
                },
                expiration_date: {
                  type: "date",
                  format: "yyyy-MM-dd"
                }
              }
      indexes :nationalities,
              type: "keyword"
      indexes :citizenships,
              type: "keyword"
      indexes :dates_of_birth,
              type: "keyword"
      indexes :start_date,
              type: "date",
              format: "yyyy-MM-dd"
      indexes :end_date,
              type: "date",
              format: "yyyy-MM-dd"
      indexes :country,
              type: "keyword"
      indexes :entity_number,
              type: "integer"
      indexes :_updated_at,
              type: "date",
              format: "strictDateOptionalTime"
    end
  end
end
