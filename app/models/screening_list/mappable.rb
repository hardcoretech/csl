# frozen_string_literal: true

module ScreeningList
  module Mappable
    def self.included(klass)
      klass.import_rate = "Daily"
      klass.class_eval do
        class << self
          attr_accessor :source
        end
      end
    end
  end
end
