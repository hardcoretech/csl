# frozen_string_literal: true

class UvlImportJob < ImportJob
  def initialize
    super
    @name = "UVL"
  end
end
