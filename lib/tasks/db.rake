# frozen_string_literal: true

namespace :db do
  desc "Create all endpoint and user indices if they do not already exist"
  task create: :environment do
    metadata_repository = MetadataRepository.new
    metadata_repository.create_index!
    Csl::Application.model_classes.each do |model_class|
      repository = CslRepository.new(index_name: model_class.name.demodulize.downcase)
      repository.create_index!
      model_class.find_or_create_metadata
    end
  end
end
