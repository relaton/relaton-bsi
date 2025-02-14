require "relaton/iso"
require_relative "bsi/version"
require_relative "bsi/util"
require_relative "bsi/item"
require_relative "bsi/bibitem"
require_relative "bsi/bibdata"
# require_relative "relaton_bsi/document_type"
# require_relative "relaton_bsi/bsi_bibliography"
# require_relative "relaton_bsi/bsi_bibliographic_item"
# require_relative "relaton_bsi/scrapper"
# require_relative "relaton_bsi/hit_collection"
# require_relative "relaton_bsi/hit"
# require_relative "relaton_bsi/xml_parser"
# require_relative "relaton_bsi/hash_converter"

module Relaton
  module Bsi
    # Returns hash of XML greammar
    # @return [String]
    def self.grammar_hash
      # gem_path = File.expand_path "..", __dir__
      # grammars_path = File.join gem_path, "grammars", "*"
      # grammars = Dir[grammars_path].sort.map { |gp| File.read gp }.join
      Digest::MD5.hexdigest RelatonBsi::VERSION + RelatonIsoBib::VERSION + RelatonBib::VERSION # grammars
    end
  end
end
