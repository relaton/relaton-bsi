# frozen_string_literal: true

module RelatonBsi
  # Scrapper.
  module Scrapper
    class << self
      # Parse page.
      # @param hit [RelatonBsi::Hit]
      # @return [Hash]
      def parse_page(hit) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        doc = hit.hit_collection.agent.get hit.hit[:url]
        BsiBibliographicItem.new(
          fetched: Date.today.to_s,
          type: "standard",
          docid: fetch_docid(doc),
          language: ["en"],
          script: ["Latn"],
          title: fetch_titles(doc),
          doctype: "specification",
          docstatus: fetch_status(doc),
          ics: fetch_ics(doc),
          date: fetch_dates(hit),
          contributor: fetch_contributors(doc),
          editorialgroup: fetch_editorialgroup(doc),
          structuredidentifier: fetch_structuredid(hit),
          abstract: fetch_abstract(doc),
          copyright: fetch_copyright(doc, hit),
          link: fetch_link(HitCollection::DOMAIN + hit.hit[:url]),
          relation: fetch_relations(doc),
          place: ["London"]
        )
      end

      private

      # @param doc [Mechanize::Page]
      # @return [Array<RelatonIsobib::Ics>]
      def fetch_ics(doc)
        doc.xpath("//tr[th='ICS']/td/node()").map(&:text).reject { |a| a.empty? }.map do |ics|
          RelatonIsoBib::Ics.new(ics)
        end
      end

      # Fetch abstracts.
      # @param doc [Mechanize::Page]
      # @return [Array<Hash>]
      def fetch_abstract(doc)
        content = doc.at("//tr[th='Descriptors']/td")
        [{ content: content.text, language: "en", script: "Latn", }]
      end

      # Fetch docid.
      # @param doc [Mechanize::Page]
      # @return [Array<Hash>]
      def fetch_docid(doc)
        docids = []
        docid = doc.at("//tr[th[.='Standard Number']]/td").text
        docids << RelatonBib::DocumentIdentifier.new(type: "BSI", id: docid)
        isbn = doc.at("//tr[th[.='ISBN']]/td").text
        docids << RelatonBib::DocumentIdentifier.new(type: "ISBN", id: isbn)
        docids
      end

      # Fetch status.
      # @param doc [Mechanize::Page]
      # @return [RelatonBib::DocumentStatus, NilClass]
      def fetch_status(doc)
        s = doc.at("//tr[th='Status']/td")
        return unless s

        RelatonBib::DocumentStatus.new(stage: s.text)
      end

      # Fetch workgroup.
      # @param doc [Mechanize::Page]
      # @return [RelatonIsoBib::EditorialGroup]
      def fetch_editorialgroup(doc)
        wg = doc.at("//tr[th='Committee']/td")
        return unless wg

        tc = RelatonIsoBib::IsoSubgroup.new name: wg.text
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
      def fetch_relations(doc)
        doc.xpath("//tr[th='Replaces']/td/a").map do |r|
          fref = RelatonBib::FormattedRef.new(content: r.text, language: "en", script: "Latn")
          link = fetch_link r[:href]
          bibitem = BsiBibliographicItem.new(formattedref: fref, type: "standard", link: link)
          { type: "complements", bibitem: bibitem }
        end
      end

      # Fetch titles.
      # @param doc [Mechanize::Page]
      # @return [Array<Hash>]
      def fetch_titles(doc)
        te = doc.at("//div[@id='title']/h2").text.strip
        ttls = RelatonBib::TypedTitleString.from_string te, "en", "Latn"
        tf = doc.at("//tr[th[.='Title in French']]/td")
        if tf
          ttls += RelatonBib::TypedTitleString.from_string tf.text.strip, "fr", "Latn"
        end
        tf = doc.at("//tr[th[.='Title in German']]/td")
        if tf
          ttls += RelatonBib::TypedTitleString.from_string tf.text.strip, "de", "Latn"
        end
        ttls
      end

      # Fetch dates
      # @param hit [RelatonBsi:Hit]
      # @return [Array<Hash>]
      def fetch_dates(hit)
        [{ type: "published", on: hit.hit[:date].to_s }]
      end

      # Fetch contributors
      # @param doc [Mechanize::Page]
      # @return [Array<Hash>]
      def fetch_contributors(doc)
        contrib = { role: [type: "publisher"] }
        contrib[:entity] = owner_entity doc
        [contrib]
      end

      # Fetch links.
      # @param url [String]
      # @return [Array<Hash>]
      def fetch_link(url)
        [{ type: "src", content: url }]
      end

      # Fetch copyright.
      # @param doc [Mechanize::Page]
      # @param hit [RelatonBsi::Hit]
      # @return [Array<Hash>]
      def fetch_copyright(doc, hit)
        owner = owner_entity doc
        from = hit.hit[:date].year.to_s
        [{ owner: [owner], from: from }]
      end

      # @param doc [Mechanize::Page]
      # @return [Hash]
      def owner_entity(doc)
        abbrev = doc.at("//tr[th='Publisher']/td").text
        case abbrev
        when "BSI"
          { abbreviation: abbrev, name: "British Standards Institution", url: "https://www.bsigroup.com/" }
        else
          { name: abbrev }
        end
      end
    end
  end
end
