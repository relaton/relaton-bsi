# frozen_string_literal: true

module RelatonBsi
  # Hit.
  class Hit < RelatonBib::Hit
    attr_writer :fetch

    # Parse page.
    # @return [RelatonBsi::BsiBibliographicItem]
    def fetch
      @fetch ||= Scrapper.parse_page self
    end
  end
end
