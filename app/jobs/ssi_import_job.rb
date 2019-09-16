# frozen_string_literal: true

class SsiImportJob < ImportJob
  def initialize
    super
    @name = "SSI"
  end
end
