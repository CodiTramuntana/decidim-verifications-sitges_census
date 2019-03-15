# frozen_string_literal: true

module SitgesCensusAuthorizationHandlerStubs
  def stub_valid_response
    stub_request(:get, URI.parse(sitges_census_url))
      .with(query: hash_including({}))
      .to_return(status: 200, body: File.open(File.dirname(__FILE__) + '/fixtures/sitges_census_valid_response.xml', 'rb').read)
  end

  def stub_invalid_response
    stub_request(:get, URI.parse(sitges_census_url))
      .with(query: hash_including({}))
      .to_return(status: 200, body: File.open(File.dirname(__FILE__) + '/fixtures/sitges_census_invalid_response.xml', 'rb').read)
  end

  private

  def sitges_census_url
    Decidim::Verifications::SitgesCensus::SitgesCensusAuthorizationConfig.url
  end
end

RSpec.configure do |config|
  config.before sitges_census_stub_type: :valid do
    stub_valid_response
  end
  config.before sitges_census_stub_type: :invalid do
    stub_invalid_response
  end
end
