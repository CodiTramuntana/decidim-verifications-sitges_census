Decidim::Verifications.register_workflow(:sitges_census_authorization_handler) do |workflow|
  workflow.form = "Decidim::Verifications::SitgesCensus::SitgesCensusAuthorizationHandler"
  workflow.engine = Decidim::Verifications::SitgesCensus::Engine
end
