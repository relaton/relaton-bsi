# frozen_string_literal: true

require "graphql/client"
require "graphql/client/http"

Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

module RelatonBsi
  # Scrapper.
  module Scrapper
    HTTP = GraphQL::Client::HTTP.new "https://shop-bsi.myshopify.com/api/2021-04/graphql.json" do
      def headers(_context)
        { "x-shopify-storefront-access-token": "c935c196c0b7d1d86bfb5139006cfd46" }
      end
    end

    Schema = GraphQL::Client.load_schema File.join(__dir__, "schema.json")

    Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

    Product = Client.parse <<~'GRAPHQL'
      fragment ProductFragment on Product {
        createdAt
        publishedAt
        updatedAt
        productType
        committee: metafield(namespace: "global", key: "committee") {
          value
        }
        designated: metafield(namespace: "global", key: "designatedStandard") {
          value
        }
        packContents: metafield(namespace: "global", key: "packContents") {
          value
        }
        summary: metafield(namespace: "global", key: "summary") {
          value
        }
        corrigendumHandle: metafield(namespace: "global", key: "corrigendumHandle") {
          value
        }
        variants(first: 250) {
          edges {
            node {
              version: metafield(namespace: "global", key: "version") {
                value
              }
              isbn: metafield(namespace: "global", key: "isbn") {
                value
              }
            }
          }
        }
        description
      }
    GRAPHQL

    Query = Client.parse <<~GRAPHQL
      query GetProducts($h0: String!) {
        productByHandle(handle: $h0) {
          ...RelatonBsi::Scrapper::Product::ProductFragment
        }
      }
    GRAPHQL

    class << self
      # Parse page.
      # @param hit [RelatonBsi::Hit]
      # @return [Hash]
      def parse_page(hit) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        # doc = hit.hit_collection.agent.get hit.hit[:url]
        result = Client.query(Query::GetProducts, variables: { h0: hit.hit[:url] })
        data = result.data.product_by_handle.to_h
        BsiBibliographicItem.new(
          fetched: Date.today.to_s,
          type: "standard",
          docid: fetch_docid(hit.hit[:code], data),
          docnumber: hit.hit[:code].match(/\d+/).to_s,
          language: ["en"],
          script: ["Latn"],
          title: fetch_titles(hit.hit[:title]),
          doctype: fetch_doctype(hit),
          docstatus: fetch_status(hit.hit[:status]),
          ics: fetch_ics(hit.hit[:ics]),
          date: fetch_dates(hit),
          contributor: fetch_contributors(hit),
          editorialgroup: fetch_editorialgroup(data),
          structuredidentifier: fetch_structuredid(hit),
          abstract: fetch_abstract(data),
          copyright: fetch_copyright(hit),
          link: fetch_link(hit.hit[:url]),
          # relation: fetch_relations(doc),
          place: ["London"],
        )
      end

      private

      # @param ics [Array<String>]
      # @return [Array<RelatonIsobib::Ics>]
      def fetch_ics(ics)
        ics.map do |s|
          code, = s.split
          RelatonIsoBib::Ics.new(code)
        end
      end

      # Fetch abstracts.
      # @param data [Hash]
      # @return [Array<Hash>]
      def fetch_abstract(data)
        return [] unless data["description"]

        [{ content: data["description"], language: "en", script: "Latn" }]
      end

      # Fetch docid.
      # @param docid [String]
      # @param data [Hash]
      # @return [Array<RelatonBib::DocumentIdentifier>]
      def fetch_docid(docid, data) # rubocop:disable Metrics/AbcSize
        ids = [{ type: "BSI", id: docid, primary: true }]
        if data.any? && data["variants"]["edges"][0]["node"]["isbn"]
          isbn = data["variants"]["edges"][0]["node"]["isbn"]["value"]
          ids << { type: "ISBN", id: isbn }
        end
        ids.map do |did|
          RelatonBib::DocumentIdentifier.new(**did)
        end
      end

      # Fetch status.
      # @param status [String]
      # @return [RelatonBib::DocumentStatus, nil]
      def fetch_status(status)
        return unless status

        RelatonBib::DocumentStatus.new(stage: status)
      end

      # Fetch workgroup.
      # @param data [Hash]
      # @return [RelatonIsoBib::EditorialGroup]
      def fetch_editorialgroup(data)
        wg = data["committee"]&.fetch("value")
        return unless wg

        tc = RelatonBib::WorkGroup.new name: wg
        RelatonIsoBib::EditorialGroup.new technical_committee: [tc]
      end

      # @param hit [RelatonBsi::Hit]
      # @return [RelatonIsoBib::StructuredIdentifier]
      def fetch_structuredid(hit)
        RelatonIsoBib::StructuredIdentifier.new project_number: hit.hit[:code]
      end

      # Fetch relations.
      # @param doc [Mechanize::Page]
      # @return [Array<Hash>]
      # def fetch_relations(doc)
      #   doc.xpath("//tr[th='Replaces']/td/a").map do |r|
      #     fref = RelatonBib::FormattedRef.new(content: r.text, language: "en", script: "Latn")
      #     link = fetch_link r[:href]
      #     bibitem = BsiBibliographicItem.new(formattedref: fref, type: "standard", link: link)
      #     { type: "complements", bibitem: bibitem }
      #   end
      # end

      # Fetch titles.
      # @param title [String]
      # @return [RelatonBib::TypedTitleStringCollection]
      def fetch_titles(title)
        RelatonBib::TypedTitleString.from_string title, "en", "Latn"
      end

      #
      # Fetch doctype.
      #
      # @param [RelatonBsi::Hit] hit hit
      #
      # @return [String] doctype
      #
      def fetch_doctype(hit)
        DocumentType.new(type: doctype(hit))
      end

      def doctype(hit)
        case hit.hit[:code]
        when /(^|\s)Flex\s/ then "flex-standard"
        when /(^|\s)PAS\s/ then "publicly-available-specification"
        else hit.hit[:doctype]
        end
      end

      # Fetch dates
      # @param hit [RelatonBsi:Hit]
      # @return [Array<Hash>]
      def fetch_dates(hit)
        [{ type: "published", on: hit.hit[:date] }]
      end

      # Fetch contributors
      # @param hit [RelatonBsi::Hit]
      # @return [Array<Hash>]
      def fetch_contributors(hit)
        contrib = { role: [type: "publisher"] }
        contrib[:entity] = owner_entity hit
        [contrib]
      end

      # Fetch links.
      # @param path [String]
      # @return [Array<Hash>]
      def fetch_link(path)
        url = "#{HitCollection::DOMAIN}/products/#{path}"
        [{ type: "src", content: url }]
      end

      # Fetch copyright.
      # @param hit [RelatonBsi::Hit]
      # @return [Array<Hash>]
      def fetch_copyright(hit)
        owner = owner_entity hit
        from = Date.parse(hit.hit[:date]).year.to_s
        [{ owner: [owner], from: from }]
      end

      # @param hit [RelatonBsi::Hit]
      # @return [Hash]
      def owner_entity(hit)
        case hit.hit[:publisher]
        when "BSI"
          { abbreviation: hit.hit[:publisher], name: "British Standards Institution", url: "https://www.bsigroup.com/" }
        else
          { name: hit.hit[:publisher] }
        end
      end
    end
  end
end
