# frozen_string_literal: true

class ConsolidatedController < ApplicationController
  ActionController::Parameters.action_on_unpermitted_parameters = :raise

  rescue_from(Exceptions::InvalidDateRangeFormat) do |_e|
    render json: { error: "Invalid Date Range Format" },
           status: :bad_request
  end

  rescue_from(ActionController::UnpermittedParameters) do |e|
    render json: { error: { unknown_parameters: e.params } },
           status: :bad_request
  end

  rescue_from(Query::InvalidParamsException) do |e|
    render json: { errors: e.errors },
           status: :bad_request
  end

  QUERY_INFO_FIELDS = %i[total offset sources_used search_performed_at].freeze

  PERMITTED_SEARCH_PARAMS = %i[callback format offset size countries q type sources name address end_date
      start_date expiration_date issue_date fuzzy_name sort].freeze

  def search
    s = params.permit(PERMITTED_SEARCH_PARAMS).except(:format)
    respond_to do |format|
      format.csv { serve_sv("csv") }
      format.tsv { serve_sv("tsv") }
      format.json do
        @query_info_fields = QUERY_INFO_FIELDS
        @search = ScreeningList::Consolidated.search_for(s)
        @search[:total] = @search[:total][:value]
        render
      end
    end
  end

  private

    def serve_sv(format)
      file = StaticFileManager.download_file("screening_list/consolidated.#{format}")
      last_modified = file.last_modified.strftime("%F")
      send_data(file.body.read,
                type: format.to_sym,
                disposition: "attachment",
                filename: "csl_#{last_modified}.#{format}")
    end
end
