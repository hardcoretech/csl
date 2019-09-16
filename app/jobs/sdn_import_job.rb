# frozen_string_literal: true

class SdnImportJob < ImportJob
  def initialize
    super
    @name = "SDN"
  end
end
