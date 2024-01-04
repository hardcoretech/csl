Rails.application.routes.draw do
  get 'consolidated_screening_list/search', to: 'consolidated#search', defaults: {format: :json}
  get 'v2/consolidated_screening_list/search', to: 'consolidated#search', defaults: {format: :json}
  get 'health', to: 'healthcheck#index'
end
