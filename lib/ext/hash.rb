# frozen_string_literal: true

class Hash
  def deep_stringify
    JSON.parse(to_json)
  end
end
