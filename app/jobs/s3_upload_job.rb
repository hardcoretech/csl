# frozen_string_literal: true

class S3UploadJob < ApplicationJob
  queue_as :csl

  def perform
    logger.info("Uploading CSV/TSV static files to S3")
    StaticFileManager.upload_all_files(ScreeningList::Consolidated)
  end
end
