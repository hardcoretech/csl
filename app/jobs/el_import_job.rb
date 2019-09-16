# frozen_string_literal: true

class ElImportJob < ImportJob
  def initialize
    super
    @name = "EL"
  end
end
