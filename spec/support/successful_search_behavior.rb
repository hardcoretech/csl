# frozen_string_literal: true

shared_examples "a successful search request" do
  specify { expect(subject.status).to eq(200) }
  specify { expect(subject.content_type).to eq("application/json; charset=utf-8") }
  specify do
    response = JSON.parse(subject.body)
    search_time = DateTime.parse(response["search_performed_at"]).to_i
    expect(search_time).to be_within(2).of(DateTime.now.utc.to_i)
  end
end
