RSpec.describe RelatonBsi::BsiBibliographicItem do
  context "subdoctype" do
    it "correct" do
      expect do
        RelatonBsi::BsiBibliographicItem.new subdoctype: "specification"
      end.to output("").to_stderr
    end

    it "incorrect" do
      expect do
        RelatonBsi::BsiBibliographicItem.new subdoctype: "type"
      end.to output(/\[relaton-bsi\] WARNING: invalid subdoctype/).to_stderr
    end
  end
end
