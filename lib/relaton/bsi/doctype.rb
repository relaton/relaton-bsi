module Relaton
  module Bsi
    class Doctype < Bib::Doctype
      TYPES = %w[
        british-standard draft-for-development published-document privately-subscribed-standard
        publicly-available-specification flex-standard international-standard technical-specification
        technical-report guide international-workshop-agreement industry-technical-agreement
        standard european-workshop-agreement fast-track-standard expert-commentary
      ].freeze

      attribute :content, :string, values: TYPES
    end
  end
end
