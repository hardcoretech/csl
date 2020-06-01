# frozen_string_literal: true

class CapImportJob < ImportJob
  def initialize
    super
    @name = "CAP"
  end
end
