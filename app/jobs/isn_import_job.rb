# frozen_string_literal: true

class IsnImportJob < ImportJob
  def initialize
    super
    @name = "ISN"
  end
end
