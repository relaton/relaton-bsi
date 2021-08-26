require "nokogiri"

module RelatonBsi
  class XMLParser < RelatonIsoBib::XMLParser
    class << self
      private

      # Override RelatonBib::XMLParser.item_data method.
      # @param isoitem [Nokogiri::XML::Element]
      # @returtn [Hash]
      def item_data(isoitem)
        data = super
        ext = isoitem.at "./ext"
        return data unless ext

        data
      end

      # @param item_hash [Hash]
      # @return [RelatonBsi::BsiBibliographicItem]
      def bib_item(item_hash)
        BsiBibliographicItem.new(**item_hash)
      end
    end
  end
end
