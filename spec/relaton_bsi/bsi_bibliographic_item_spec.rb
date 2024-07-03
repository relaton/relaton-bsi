RSpec.describe RelatonBsi::BsiBibliographicItem do
  context "subdoctype" do
    it "correct" do
      expect do
        RelatonBsi::BsiBibliographicItem.new subdoctype: "specification"
      end.to output("").to_stderr_from_any_process
    end

    it "incorrect" do
      expect do
        RelatonBsi::BsiBibliographicItem.new subdoctype: "type"
      end.to output(/\[relaton-bsi\] WARN: invalid subdoctype/).to_stderr_from_any_process
    end
  end
end
