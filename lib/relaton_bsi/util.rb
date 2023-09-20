module RelatonBsi
  module Util
    extend RelatonBib::Util

    def self.logger
      RelatonBsi.configuration.logger
    end
  end
end
