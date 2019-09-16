# frozen_string_literal: true

describe Csl::Application do
  describe ".model_classes" do
    subject { described_class.model_classes }

    it { is_expected.to include(ScreeningList::Dpl) }

    it { is_expected.not_to include(ScreeningList::Consolidated) }
  end
end
