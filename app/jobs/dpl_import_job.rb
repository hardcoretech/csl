# frozen_string_literal: true

class DplImportJob < ImportJob
  def initialize
    super
    @name = "DPL"
  end
end
