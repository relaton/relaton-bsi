describe RelatonBsi::DocumentType do
  context "doctype" do
    it "correct" do
      expect do
        RelatonBsi::DocumentType.new type: "british-standard"
      end.to output("").to_stderr_from_any_process
    end

    it "incorrect" do
      expect do
        RelatonBsi::DocumentType.new type: "type"
      end.to output(/\[relaton-bsi\] WARN: invalid doctype: `type`/).to_stderr_from_any_process
    end
  end
end
