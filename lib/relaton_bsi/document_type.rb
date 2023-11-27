module RelatonBsi
  class DocumentType < RelatonBib::DocumentType
    DOCTYPES = %w[
      british-standard draft-for-development published-document privately-subscribed-standard
      publicly-available-specification flex-standard international-standard technical-specification
      technical-report guide international-workshop-agreement industry-technical-agreement
      standard european-workshop-agreement fast-track-standard expert-commentary
    ].freeze

    def initialize(type:, abbreviation: nil)
      check_type type
      super
    end

    def check_type(type)
      unless DOCTYPES.include? type
        Util.warn "WARNING: invalid doctype: `#{type}`"
      end
    end
  end
end
