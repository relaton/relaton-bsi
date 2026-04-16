module Relaton
  module Bsi
    class Bibitem < Item
      model ItemData
      include Bib::BibitemShared
    end
  end
end
