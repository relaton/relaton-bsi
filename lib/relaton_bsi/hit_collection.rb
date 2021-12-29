# frozen_string_literal: true

require "algolia"
require "relaton_bsi/hit"

module RelatonBsi
  # Page of hit collection.
  class HitCollection < RelatonBib::HitCollection
    DOMAIN = "https://shop.bsigroup.com"


    # @param ref [String]
    # @param year [String]
    def initialize(ref, year = nil)
      super ref, year
      # @agent = Mechanize.new
      # resp = agent.get "#{DOMAIN}/SearchResults/?q=#{ref}"
      config = Algolia::Search::Config.new(application_id: "575YE157G9", api_key: "a057b4e74099445df2eddb7940828a10")
      client = Algolia::Search::Client.new config, logger: ::Logger.new($stderr)
      index = client.init_index "shopify_products"
      resp = index.search text # , facetFilters: "product_type:standard"
      @array = hits resp[:hits]
    end

    private

    # @param hits [Array<Hash>]
    # @return [Array<RelatonBsi::Hit>]
    def hits(hits) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      hits.map do |h|
        code = h[:meta][:global][:primaryDesignator].sub(/\sLOOSELEAF|\s\(A5 LAMINATED\)/, "")
        Hit.new(
          {
            code: code,
            title: h[:title],
            url: h[:handle],
            date: h[:meta][:global][:publishedDate],
            publisher: h[:meta][:global][:publisher],
            status: h[:meta][:global][:status],
            ics: h[:meta][:global][:icsCodesAlgoliaStringArray],
            doctype: h[:product_type],
          }, self
        )
      end.sort_by { |h| h.hit[:date] }.reverse
    end
  end
end
