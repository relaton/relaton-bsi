module RelatonBsi
  class BsiBibliographicItem < RelatonIsoBib::IsoBibliographicItem
    SUBDOCTYPES = %w[specification method-of-test method-of-specifying vocabulary code-of-practice].freeze

    def initialize(**args) # rubocop:disable Metrics/AbcSize
      if args[:subdoctype] && !SUBDOCTYPES.include?(args[:subdoctype])
        Util.warn "WARNING: invalid subdoctype: `#{args[:subdoctype]}`"
        Util.warn "Allowed subdoctypes are: `#{SUBDOCTYPES.join('`, `')}`"
      end
      super
    end

    #
    # Fetch flavor schema version
    #
    # @return [String] flavor schema version
    #
    def ext_schema
      @ext_schema ||= schema_versions["relaton-model-bsi"]
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [Boolean] :bibdata
    # @option opts [String] :lang language
    # @return [String] XML
    # def to_xml(**opts) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
    #   super(**opts) do |b|
    #     if opts[:bibdata] && (has_ext_attrs? || price_code || !cen_processing.nil?)
    #       ext = b.ext do
    #         b.doctype doctype if doctype
    #         b.docsubtype subdoctype if subdoctype
    #         # b.horizontal horizontal unless horizontal.nil?
    #         editorialgroup&.to_xml b
    #         ics.each { |i| i.to_xml b }
    #         structuredidentifier&.to_xml b
    #         b.stagename stagename if stagename
    #       end
    #       ext["schema-version"] = ext_schema unless opts[:embeded]
    #     end
    #   end
    # end

    # @param hash [Hash]
    # @return [RelatonBsi::BsiBibliographicItem]
    def self.from_hash(hash)
      item_hash = ::RelatonBsi::HashConverter.hash_to_bib(hash)
      new(**item_hash)
    end
  end
end
