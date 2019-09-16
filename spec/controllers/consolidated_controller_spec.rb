# frozen_string_literal: true

describe ConsolidatedController, type: :controller do
  describe "#search" do
    context "with unpermitted parameter" do
      it "responds with 400" do
        get :search, params: { foo: :freddy }
        expect(response.status).to eq(400)
      end
    end

    context "query with negative offset" do
      before { get :search, format: :json, params: { offset: -1 } }
      it { expect(response.status).to eq(400) }
      it { expect(response.body).to include("Offset must be greater than or equal to 0") }
    end

    context "with invalid date range exception" do
      before { get :search, format: :json, params: { start_date: "nope" } }
      it { expect(response.status).to eq(400) }
    end
  end
end
