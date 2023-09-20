describe RelatonBsi do
  after { RelatonBsi.instance_variable_set :@configuration, nil }

  it "configure" do
    RelatonBsi.configure do |conf|
      conf.logger = :logger
    end
    expect(RelatonBsi.configuration.logger).to eq :logger
  end
end
