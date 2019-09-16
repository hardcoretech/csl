# frozen_string_literal: true

type = entry[:_source][:type].casecmp("vessel").zero? ? "vessel" : "default"
json.partial! "consolidated/plc/#{type}/entry", entry: entry
