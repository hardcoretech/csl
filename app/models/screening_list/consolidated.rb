# frozen_string_literal: true

module ScreeningList
  class Consolidated
    include Searchable
    self.model_classes = [ScreeningList::Cap,
                          ScreeningList::Dpl,
                          ScreeningList::Dtc,
                          ScreeningList::El,
                          ScreeningList::Fse,
                          ScreeningList::Isn,
                          ScreeningList::Meu,
                          ScreeningList::Plc,
                          ScreeningList::Sdn,
                          ScreeningList::Ssi,
                          ScreeningList::Uvl,
                          ScreeningList::Mbs,]
    self.fetch_all_sort_by = "name.keyword"

    include SeparatedValuesable
    self.separated_values_config = [
      :_id,
      { source: [:full_name] },
      :entity_number,
      :type,
      :programs,
      :name,
      :title,
      { addresses: [:address, :city, :state, :postal_code, :country] },
      :federal_register_notice,
      :start_date,
      :end_date,
      :standard_order,
      :license_requirement,
      :license_policy,
      :call_sign,
      :vessel_type,
      :gross_tonnage,
      :gross_registered_tonnage,
      :vessel_flag,
      :vessel_owner,
      :remarks,
      :source_list_url,
      :alt_names,
      :citizenships,
      :dates_of_birth,
      :nationalities,
      :places_of_birth,
      :source_information_url,
      { ids: [:country, :expiration_date, :issue_date, :number, :type] }
    ]
  end
end
