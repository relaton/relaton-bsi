# frozen_string_literal: true

require "algolia"
require "relaton_bsi/hit"

module RelatonBsi
  # Page of hit collection.
  class HitCollection < RelatonBib::HitCollection
    DOMAIN = "https://shop.bsigroup.com"

    #
    # Initialize a new HitCollection.
    #
    # @param ref [String] reference
    # @param year [String] year
    #
    def initialize(ref, year = nil)
      super ref, year
      config = Algolia::Search::Config.new(
        application_id: "575YE157G9",
        api_key: "a057b4e74099445df2eddb7940828a10",
      )
      client = Algolia::Search::Client.new config, logger: ::Logger.new($stderr)
      index = client.init_index "shopify_products"
      resp = index.search text # , facetFilters: "product_type:standard"
      @array = create_hits resp[:hits]
    end

    #
    # Filter the search results for a BSI standard.
    #
    # @param [MatchData] code_parts parts of document identifier
    #
    # @return [self] filtered search results
    #
    def filter_hits!(code_parts)
      hits = filter code_parts
      hits = filter code_parts, skip_rest: true if hits.empty?
      hits = filter code_parts, drop_amd: true if hits.empty?
      @array = hits
      self
    end

    private

    #
    # Create hits from search results.
    #
    # @param hits [Array<Hash>] search results
    #
    # @return [Array<RelatonBsi::Hit>] hits
    #
    def create_hits(hits) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      hits.each_with_object([]) do |h, obj|
        next unless h[:meta][:global][:publishedDate]

        code = h[:meta][:global][:primaryDesignator]
        code = code.is_a?(Array) ? code.first : code
        code.sub!(/\s?(?:LOOSELEAF|\(A5 LAMINATED\)|-\s?TC$)/, "")
        obj << Hit.new(
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

    #
    # Select hits that match the document identifier.
    #
    # @param [MatchData] code_parts parts of document identifier
    # @param [Boolean] drop_amd drop amendments and corrigendums
    # @param [Boolean] skip_rest skip rest suffix of document identifier
    #
    def filter(code_parts, drop_amd: false, skip_rest: false) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      @array.select do |i|
        code = drop_amd ? i.hit[:code].sub(/\+[AC]\d+.*$/, "") : i.hit[:code]
        cp = BsiBibliography.code_parts code
        match = cp[:code] == code_parts[:code] && cp[:a] == code_parts[:a] &&
          (!code_parts[:y] || cp[:y] == code_parts[:y]) &&
          (skip_rest || cp[:rest] == code_parts[:rest])
        i.hit[:code] = code if drop_amd && match
        match
      end
    end
  end
end
