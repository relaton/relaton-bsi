# frozen_string_literal: true

require "jing"

RSpec.describe RelatonBsi do
  it "has a version number" do
    expect(RelatonBsi::VERSION).not_to be nil
  end

  it "returs grammar hash" do
    hash = RelatonBsi.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end

  it "gets code" do
    VCR.use_cassette "bibdata" do
      file = "spec/fixtures/bibdata.xml"
      bib = RelatonBsi::BsiBibliography.get("BS EN ISO 8848", nil, {})
      xml = bib.to_xml bibdata: true
      write_file file, xml
      expect(xml).to be_equivalent_to read_xml(file)
      schema = Jing.new "spec/fixtures/isobib.rng"
      errors = schema.validate file
      expect(errors).to eq []
    end
  end

  it "gets code and year" do
    VCR.use_cassette "bibdata" do
      file = "spec/fixtures/bibdata_year.xml"
      bib = RelatonBsi::BsiBibliography.get("BS EN ISO 8848", "2021", {})
      xml = bib.to_xml bibdata: true
      write_file file, xml
      expect(xml).to be_equivalent_to read_xml(file)
    end
  end

  it "gets code and year in code" do
    VCR.use_cassette "bibdata" do
      file = "spec/fixtures/bibdata_year.xml"
      bib = RelatonBsi::BsiBibliography.get("BS EN ISO 8848:2021")
      xml = bib.to_xml bibdata: true
      write_file file, xml
      expect(xml).to be_equivalent_to read_xml(file)
    end
  end

  it "warns when year is wrong" do
    VCR.use_cassette "wrong_year" do
      expect { RelatonBsi::BsiBibliography.get("BS EN ISO 8848", "2018", {}) }
        .to output(%r{matches found for 2021, 2017})
        .to_stderr
    end
  end

  it "return nil when reference not found" do
    VCR.use_cassette "not_found" do
      result = RelatonBsi::BsiBibliography.get "BS NOT FOUND"
      expect(result).to be_nil
    end
  end

  it "fetch hits" do
    VCR.use_cassette "hits" do
      hit_collection = RelatonBsi::BsiBibliography.search("BS EN ISO 8848")
      expect(hit_collection.fetched).to be false
      expect(hit_collection.fetch).to be_instance_of RelatonBsi::HitCollection
      expect(hit_collection.fetched).to be true
      expect(hit_collection.first).to be_instance_of RelatonBsi::Hit
      expect(hit_collection.to_s).to eq "<RelatonBsi::HitCollection:"\
        "#{format('%<id>#.14x', id: hit_collection.object_id << 1)} "\
        "@ref=BS EN ISO 8848 @fetched=true>"
    end
  end

  it "return string of hit" do
    VCR.use_cassette "hits" do
      hits = RelatonBsi::BsiBibliography.search("BS EN ISO 8848").fetch
      expect(hits.first.to_s).to eq "<RelatonBsi::Hit:"\
        "#{format('%<id>#.14x', id: hits.first.object_id << 1)} "\
        '@text="BS EN ISO 8848" @fetched="true" @fullIdentifier="BSENISO8848-2021:2021"'\
        ' @title="BS EN ISO 8848:2021">'
    end
  end

  it "document with multiple ICS" do
    VCR.use_cassette "bs_202000_2020" do
      bib = RelatonBsi::BsiBibliography.get "BS 202000:2020"
      expect(bib.docidentifier[0].id).to eq "BS 202000:2020"
      expect(bib.ics[0].code).to eq "01.120"
      expect(bib.ics[1].code).to eq "03.100.70"
    end
  end

  it "could not access site" do
    agent = double "agent"
    expect(agent).to receive(:get).with(kind_of(String)).and_raise SocketError
    expect(Mechanize).to receive(:new).and_return agent
    expect do
      RelatonBsi::BsiBibliography.search "BS EN ISO 8848"
    end.to raise_error RelatonBib::RequestError
  end
end
