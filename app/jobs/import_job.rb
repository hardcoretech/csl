# frozen_string_literal: true

class ImportJob < ApplicationJob
  queue_as :csl

  def perform
    logger.info("Importing #{@name}")
    importer_class = "ScreeningList::#{@name.titleize}Data".constantize
    importer_class.new.import
  end
end
