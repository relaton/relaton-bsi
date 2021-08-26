RSpec.describe RelatonBsi::BsiBibliographicItem do
  context "doctype" do
    it "correct" do
      expect do
        RelatonBsi::BsiBibliographicItem.new doctype: "british-standard"
      end.to output("").to_stderr
    end

    it "incorrect" do
      expect do
        RelatonBsi::BsiBibliographicItem.new doctype: "type"
      end.to output(/\[relaton-iso-bib\] WARNING: invalid doctype/).to_stderr
    end
  end

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
