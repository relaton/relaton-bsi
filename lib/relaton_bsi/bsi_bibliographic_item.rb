module RelatonBsi
  class BsiBibliographicItem < RelatonIsoBib::IsoBibliographicItem
    TYPES = %w[
      specification management-systems-standard code-of-practice guide
      method-of-test method-of-specifying vocabulary classification
    ].freeze

    # @return [String, nil]
    attr_reader :price_code

    # @return [Boolean, nil]
    attr_reader :cen_processing

    # @params price_code [String, nil]
    # @param cen_processing [Boolean, nil]
    def initialize(**args)
      # if args[:doctype] && !TYPES.include?(args[:doctype])
      #   warn "[relaton-bsi] WARNING: invalid doctype: #{args[:doctype]}"
      # end
      @price_code = args.delete :price_code
      @cen_processing = args.delete :cen_processing
      super
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [Boolean] :bibdata
    # @option opts [String] :lang language
    # @return [String] XML
    def to_xml(**opts) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
      super **opts do |b|
        if opts[:bibdata] && (has_ext_attrs? || price_code ||
          !cen_processing.nil?)
          b.ext do
            b.doctype doctype if doctype
            b.horizontal horizontal unless horizontal.nil?
            editorialgroup&.to_xml b
            ics.each { |i| i.to_xml b }
            structuredidentifier&.to_xml b
            b.stagename stagename if stagename
            b.send "price-code", price_code if price_code
            b.send "cen-processing", cen_processing unless cen_processing.nil?
          end
        end
      end
    end

    # @param hash [Hash]
    # @return [RelatonBsi::BsiBibliographicItem]
    def self.from_hash(hash)
      item_hash = ::RelatonBsi::HashConverter.hash_to_bib(hash)
      new **item_hash
    end
  end
end
