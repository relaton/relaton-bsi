RSpec.describe RelatonBsi::XMLParser do
  it "create bibitem from XML" do
    xml = File.read "spec/fixtures/bibdata.xml"
    bib = RelatonBsi::XMLParser.from_xml xml
    expect(bib.to_xml(bibdata: true)).to be_equivalent_to xml
  end
end
