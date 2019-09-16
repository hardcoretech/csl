# frozen_string_literal: true

module Utils
  module_function

  def generate_id(hash = {}, keys = [])
    Digest::SHA1.hexdigest(keys.map { |k| hash[k] }.join)
  end

  def older_than(timestamp)
    Jbuilder.new do |json|
      json.query do
        json.range do
          json._updated_at do
            json.lt timestamp
          end
        end
      end
    end.attributes!
  end
end
