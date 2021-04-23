require "relaton/processor"

module RelatonBsi
  class Processor < Relaton::Processor
    def initialize
      @short = :relaton_bsi
      @prefix = "BSI"
      @defaultprefix = %r{^BSI\s}
      @idtype = "BSI"
    end

    # @param code [String]
    # @param date [String, NilClass] year
    # @param opts [Hash]
    # @return [RelatonBsi::BsiBibliographicItem]
    def get(code, date, opts)
      ::RelatonBsi::BsiBibliography.get(code, date, opts)
    end

    # @param xml [String]
    # @return [RelatonBsi::BsiBibliographicItem]
    def from_xml(xml)
      ::RelatonBsi::XMLParser.from_xml xml
    end

    # @param hash [Hash]
    # @return [RelatonBsi::BsiBibliographicItem]
    def hash_to_bib(hash)
      ::RelatonBsi::BsiBibliographicItem.from_hash hash
    end

    # Returns hash of XML grammar
    # @return [String]
    def grammar_hash
      @grammar_hash ||= ::RelatonBsi.grammar_hash
    end
  end
end
