# frozen_string_literal: true

RSpec.describe RelatonBsi::HashConverter do
  it "create bibitem from hash" do
    hash = YAML.load_file "spec/fixtures/bibdata.yaml"
    bib = RelatonBsi::BsiBibliographicItem.from_hash hash
    expect(bib.to_hash).to eq hash
  end
end
