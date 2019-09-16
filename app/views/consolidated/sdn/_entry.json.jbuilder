# frozen_string_literal: true

type = entry[:_source][:type].casecmp("vessel").zero? ? "vessel" : "default"
json.partial! "consolidated/sdn/#{type}/entry", entry: entry
