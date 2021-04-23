module RelatonBsi
  class HashConverter < RelatonIsoBib::HashConverter
    class << self
      private

      #
      # Ovverides superclass's method
      #
      # @param item [Hash]
      # @retirn [RelatonBsi::BsiBibliographicItem]
      def bib_item(item)
        BsiBibliographicItem.new(**item)
      end
    end
  end
end
