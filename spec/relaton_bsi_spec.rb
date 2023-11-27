# frozen_string_literal: true

require "jing"

RSpec.describe RelatonBsi do
  before { RelatonBsi.instance_variable_set :@configuration, nil }

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
      schema = Jing.new "grammars/relaton-bsi-compile.rng"
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

  it "wipe out trailing ' - TC'" do
    VCR.use_cassette "bs_en_iso_19011_2018" do
      bib = RelatonBsi::BsiBibliography.get("BS EN ISO 19011:2018")
      expect(bib.docidentifier.first.id).to eq "BS EN ISO 19011:2018"
    end
  end

  it "gets code without rest suffix" do
    VCR.use_cassette "bs_5266_1" do
      bib = RelatonBsi::BsiBibliography.get("BS 5266-1")
      expect(bib.docidentifier.first.id).to eq "BS 5266-1"
    end
  end

  it "code with corrigendum" do
    VCR.use_cassette "code_with_corrigendum" do
      bib = RelatonBsi::BsiBibliography.get("PAS 2035/2030:2019+A1:2022")
      expect(bib.docidentifier.first.id).to eq "PAS 2035/2030:2019+A1:2022"
      expect(bib.doctype.type).to eq "publicly-available-specification"
    end
  end

  it "drops corrigendum" do
    VCR.use_cassette "drops_corrigendum" do
      bib = RelatonBsi::BsiBibliography.get("PAS 2031:2019")
      expect(bib.docidentifier.first.id).to eq "PAS 2031:2019"
      expect(bib.doctype.type).to eq "publicly-available-specification"
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

  it "gets PAS" do
    VCR.use_cassette "pas_2050_2011" do
      bib = RelatonBsi::BsiBibliography.get "PAS 2050:2011"
      expect(bib.docidentifier[0].id).to eq "PAS 2050:2011"
      expect(bib.doctype.type).to eq "publicly-available-specification"
    end
  end

  it "gets Flex", vcr: { cassette_name: "flex_0" } do
    bib = RelatonBsi::BsiBibliography.get "BSI Flex 0"
    expect(bib.docidentifier[0].id).to eq "BSI Flex 0 v2.0-08"
    expect(bib.doctype.type).to eq "flex-standard"
  end

  it "BS EN ISO 9001" do
    VCR.use_cassette "bs_en_iso_9001" do
      bib = RelatonBsi::BsiBibliography.get "BS EN ISO 9001"
      expect(bib.docidentifier[0].id).to eq "BS EN ISO 9001"
    end
  end

  it "BS EN ISO 14044:2006+A2" do
    VCR.use_cassette "bs_en_iso_14044_2006_a2" do
      bib = RelatonBsi::BsiBibliography.get "BS EN ISO 14044:2006+A2"
      expect(bib.docidentifier[0].id).to eq "BS EN ISO 14044:2006+A2:2020"
    end
  end

  it "BS 8000-0" do
    VCR.use_cassette "bs_8000_0" do
      bib = RelatonBsi::BsiBibliography.get "BS 8000-0"
      expect(bib.docidentifier[0].id).to eq "BS 8000-0"
    end
  end

  it "warns when year is wrong" do
    VCR.use_cassette "wrong_year" do
      expect { RelatonBsi::BsiBibliography.get("BS EN ISO 8848", "2018", {}) }
        .to output(%r{matches found for `2022`, `2021`, `2017`})
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
      expect(hit_collection.to_s).to eq(
        "<RelatonBsi::HitCollection:"\
        "#{format('%<id>#.14x', id: hit_collection.object_id << 1)} " \
        "@ref=BS EN ISO 8848 @fetched=true>",
      )
    end
  end

  it "return string of hit" do
    VCR.use_cassette "hits" do
      hits = RelatonBsi::BsiBibliography.search("BS EN ISO 8848").fetch
      expect(hits.first.to_s).to eq(
        "<RelatonBsi::Hit:#{format('%<id>#.14x', id: hits.first.object_id << 1)} " \
        '@text="BS EN ISO 8848" @fetched="true" @fullIdentifier=' \
        '"BSENISO8848-2022:2022" @title="BS EN ISO 8848:2022">',
      )
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

  context "fetch Expert commentary" do
    it "full type name", vcr: { cassette_name: "excomm_full" } do
      bib = RelatonBsi::BsiBibliography.get "BS 7273-4:2015+A1:2021 Expert commentary"
      expect(bib.docidentifier[0].id).to eq "BS 7273-4:2015+A1:2021 ExComm"
    end

    it "short type name", vcr: { cassette_name: "excomm_short" } do
      bib = RelatonBsi::BsiBibliography.get "BS EN ISO 13485 ExComm"
      expect(bib.docidentifier[0].id).to eq "BS EN ISO 13485 Expert Commentary"
    end
  end

  it "could not access site" do
    index = double "algolia index"
    client = double "algolia client", init_index: index
    expect(index).to receive(:search).and_raise Algolia::AlgoliaUnreachableHostError
    expect(Algolia::Search::Client).to receive(:new).and_return client
    # expect(RelatonBsi::Scrapper::Client).to receive(:query).and_raise
    expect do
      RelatonBsi::BsiBibliography.search "BS EN ISO 8848"
    end.to raise_error RelatonBib::RequestError
  end
end
