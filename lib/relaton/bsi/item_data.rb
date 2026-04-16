module Relaton
  module Bsi
    class ItemData < Iso::ItemData
      def create_id(without_date: false)
        docid = docidentifier.find(&:primary) || docidentifier.first
        return unless docid

        id_content = without_date ? docid.content.sub(/:\d{4}$/, "") : docid.content
        self.id = id_content.gsub(/\W+/, "")
      end
    end
  end
end
