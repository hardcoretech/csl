# frozen_string_literal: true

shared_examples "an empty result" do
  subject { JSON.parse(response.body)["results"].length }
  it { is_expected.to eq(0) }
end

shared_examples "an empty result when a query doesn't match any documents" do |original_params|
  # Allows this shared example to support queries that involves extra parameters
  # ie.: a specific source for tariff rates
  original_params ||= {}
  let(:params) { original_params.merge(q: "asdzxcasd") }
  it_behaves_like "an empty result"
end

shared_examples "an empty result when a countries search doesn't match any documents" do
  let(:params) { { countries: "YY" } }
  it_behaves_like "an empty result"
end
