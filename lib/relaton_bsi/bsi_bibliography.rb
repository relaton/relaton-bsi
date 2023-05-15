# frozen_string_literal: true

# require "mechanize"
require "relaton_iso_bib"
require "relaton_bsi/bsi_bibliographic_item"
require "relaton_bsi/scrapper"
require "relaton_bsi/hit_collection"
require "relaton_bsi/hit"
require "relaton_bsi/xml_parser"
require "relaton_bsi/hash_converter"

module RelatonBsi
  # Class methods for search ISO standards.
  class BsiBibliography
    class << self
      # @param text [String]
      # @return [RelatonBsi::HitCollection]
      def search(text, year = nil)
        code = text.sub(/^BSI\s/, "")
        HitCollection.new code, year
      rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
             EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
             Net::ProtocolError, Algolia::AlgoliaUnreachableHostError => e
        raise RelatonBib::RequestError, e.message
      end

      #
      # @param code [String] the BSI standard Code to look up
      # @param year [String] the year the standard was published (optional)
      # @param opts [Hash] options
      # @option opts [Boolean] :all_parts if all-parts reference is required
      # @option opts [Boolean] :no_year if last published document is required
      #
      # @return [String] Relaton XML serialisation of reference
      def get(code, year = nil, opts = {})
        # y = code.split(":")[1]
        year ||= code_parts(code)[:year]
        ret = bib_get(code, year, opts)
        return nil if ret.nil?

        ret = ret.to_most_recent_reference unless year || opts[:keep_year]
        # ret = ret.to_all_parts if opts[:all_parts]
        ret
      end

      #
      # Destruct code to its parts.
      #
      # @param [String] code document identifier
      #
      # @return [MatchData] parts of the code
      #
      def code_parts(code)
        %r{
          ^(?:BSI\s)?(?<code>(?:[A-Z]+\s)*[^:\s+]+(?:\s\d+)?)
          (?::(?<year>\d{4}))?
          (?:\+(?<a>[^:\s]+)(?::(?<y>\d{4}))?)?
          (?:\s(?<rest>.+))?
        }x.match code
      end

      private

      def fetch_ref_err(code, year, missed_years) # rubocop:disable Metrics/MethodLength
        y = code_parts(code)[:year]
        id = year && !y ? "#{code}:#{year}" : code
        warn "[relaton-bsi] WARNING: no match found online for #{id}. "\
             "The code must be exactly like it is on the standards website."
        unless missed_years.empty?
          warn "[relaton-bsi] (There was no match for #{year}, though there "\
               "were matches found for #{missed_years.join(', ')}.)"
        end
        # if /\d-\d/.match? code
        #   warn "[relaton-bsi] The provided document part may not exist, or "\
        #     "the document may no longer be published in parts."
        # else
        #   warn "[relaton-bsi] If you wanted to cite all document parts for "\
        #     "the reference, use \"#{code} (all parts)\".\nIf the document "\
        #     "is not a standard, use its document type abbreviation (TS, TR, "\
        #     "PAS, Guide)."
        # end
        nil
      end

      #
      # Search for a BSI standard.
      #
      # @param [String] code the BSI standard Code to look up
      #
      # @return [RelatonBsi::HitCollection] a collection of hits
      #
      def search_filter(code)
        cp = code_parts code
        warn "[relaton-bsi] (\"#{code}\") fetching..."
        return [] unless cp

        search(code).filter_hits!(cp)
      end

      # Sort through the results from Isobib, fetching them three at a time,
      # and return the first result that matches the code,
      # matches the year (if provided), and which # has a title (amendments do not).
      # Only expects the first page of results to be populated.
      # Does not match corrigenda etc (e.g. ISO 3166-1:2006/Cor 1:2007)
      # If no match, returns any years which caused mismatch, for error reporting
      def results_filter(result, year)
        missed_years = []
        result.each do |r|
          pyear = code_parts(r.hit[:code])[:year]
          if !year || year == pyear
            ret = r.fetch
            return { ret: ret } if ret
          end

          missed_years << pyear
        end
        { years: missed_years }
      end

      def bib_get(code, year, _opts)
        result = search_filter(code) || return
        ret = results_filter(result, year)
        if ret[:ret]
          warn "[relaton-bsi] (\"#{code}\") found #{ret[:ret].docidentifier.first&.id}"
          ret[:ret]
        else
          fetch_ref_err(code, year, ret[:years])
        end
      end
    end
  end
end
