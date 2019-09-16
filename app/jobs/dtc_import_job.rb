# frozen_string_literal: true

class DtcImportJob < ImportJob
  def initialize
    super
    @name = "DTC"
  end
end
