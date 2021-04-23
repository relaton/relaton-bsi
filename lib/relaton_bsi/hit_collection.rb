# frozen_string_literal: true

require "relaton_bsi/hit"

module RelatonBsi
  # Page of hit collection.
  class HitCollection < RelatonBib::HitCollection
    DOMAIN = "https://shop.bsigroup.com"

    # @return [Mechanize]
    attr_reader :agent

    # @param ref [String]
    # @param year [String]
    def initialize(ref, year = nil)
      super ref, year
      @agent = Mechanize.new
      resp = agent.get "#{DOMAIN}/SearchResults/?q=#{ref}"
      @array = hits resp
    end

    private

    # @param resp [Mechanize::Page]
    # @return [Array<RelatonBsi::Hit>]
    def hits(resp)
      resp.xpath("//div[@class='resultsInd']").map do |h|
        ref = h.at('div/h2/a')
        code = ref.text.strip
        url = ref[:href]
        d = h.at("//div/strong[.='Published Date:']/following-sibling::strong").text
        date = Date.parse(d)
        Hit.new({ code: code, url: url, date: date }, self)
      end
    end
  end
end
