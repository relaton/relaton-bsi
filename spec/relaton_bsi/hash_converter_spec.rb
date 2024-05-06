# frozen_string_literal: true

RSpec.describe RelatonBsi::HashConverter do
  it "create bibitem from hash" do
    hash = YAML.load_file "spec/fixtures/bibdata.yaml"
    bib = RelatonBsi::BsiBibliographicItem.from_hash hash
    expect(bib.to_h).to eq hash
  end

  it "create document type from hash" do
    doctype = described_class.send :create_doctype, type: "type"
    expect(doctype).to be_instance_of RelatonBsi::DocumentType
    expect(doctype.type).to eq "type"
  end
end
