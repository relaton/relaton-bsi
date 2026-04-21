module Relaton
  module Bsi
    class Bibdata < Item
      model ItemData
      include Bib::BibdataShared
    end
  end
end
