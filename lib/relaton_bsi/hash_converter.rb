module RelatonBsi
  module HashConverter
    include RelatonIsoBib::HashConverter
    extend self

    private

    #
    # Ovverides superclass's method
    #
    # @param item [Hash]
    # @retirn [RelatonBsi::BsiBibliographicItem]
    def bib_item(item)
      BsiBibliographicItem.new(**item)
    end

    def create_doctype(**args)
      DocumentType.new(**args)
    end
  end
end
