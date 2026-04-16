require_relative "doctype"

module Relaton
  module Bsi
    class Ext < Bib::Ext
      attribute :doctype, Doctype
      attribute :ics, Bib::ICS, collection: true
      attribute :structuredidentifier, Iso::StructuredIdentifier, collection: true, initialize_empty: true
      attribute :stagename, Iso::Stagename

      xml { map_element "stagename", to: :stagename }
      key_value { map_element "stagename", to: :stagename }

      def get_schema_version = Relaton.schema_versions["relaton-model-bsi"]
    end
  end
end
