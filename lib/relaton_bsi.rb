# frozen_string_literal: true

require "relaton_iso_bib"
require_relative "relaton_bsi/version"
require "relaton_bsi/config"
require "relaton_bsi/util"
require "relaton_bsi/bsi_bibliography"
require "relaton_bsi/bsi_bibliographic_item"
require "relaton_bsi/scrapper"
require "relaton_bsi/hit_collection"
require "relaton_bsi/hit"
require "relaton_bsi/xml_parser"
require "relaton_bsi/hash_converter"

module RelatonBsi
  # Returns hash of XML greammar
  # @return [String]
  def self.grammar_hash
    # gem_path = File.expand_path "..", __dir__
    # grammars_path = File.join gem_path, "grammars", "*"
    # grammars = Dir[grammars_path].sort.map { |gp| File.read gp }.join
    Digest::MD5.hexdigest RelatonBsi::VERSION + RelatonIsoBib::VERSION + RelatonBib::VERSION # grammars
  end
end
