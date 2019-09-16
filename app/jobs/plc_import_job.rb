# frozen_string_literal: true

class PlcImportJob < ImportJob
  def initialize
    super
    @name = "Plc"
  end
end
