# frozen_string_literal: true

require_relative "relaton_bsi/version"
require "relaton_bsi/bsi_bibliography"

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
