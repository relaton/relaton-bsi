RSpec.describe RelatonBsi::XMLParser do
  it "create bibitem from XML" do
    xml = File.read "spec/fixtures/bibdata.xml"
    bib = RelatonBsi::XMLParser.from_xml xml
    expect(bib.to_xml(bibdata: true)).to be_equivalent_to xml
  end

  it "create_doctype" do
    elm = Nokogiri::XML('<doctype abbreviation="IS">international-standard</doctype>').root
    dt = RelatonBsi::XMLParser.send :create_doctype, elm
    expect(dt).to be_instance_of RelatonBsi::DocumentType
    expect(dt.type).to eq "international-standard"
    expect(dt.abbreviation).to eq "IS"
  end
end
