require_relative "doctype"

module Relaton
  module Bsi
    class Ext < Lutaml::Model::Serializable
      attribute :schema_version, :string, method: :get_schema_version
      attribute :doctype, Doctype
      attribute :subdoctype, :string
      attribute :flavor, :string
      attribute :ics, Bib::ICS, collection: true
      attribute :structuredidentifier, Iso::StructuredIdentifier, collection: true, initialize_empty: true
      attribute :stagename, Iso::Stagename

      xml do
        root "ext"
        map_attribute "schema-version", to: :schema_version
        map_element "doctype", to: :doctype
        map_element "subdoctype", to: :subdoctype
        map_element "flavor", to: :flavor
        map_element "ics", to: :ics
        map_element "stagename", to: :stagename
        map_element "structuredidentifier", to: :structuredidentifier
      end

      def get_schema_version
        Relaton.schema_versions["relaton-model-bsi"]
      end
    end
  end
end
