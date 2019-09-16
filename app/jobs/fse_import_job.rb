# frozen_string_literal: true

class FseImportJob < ImportJob
  def initialize
    super
    @name = "FSE"
  end
end
