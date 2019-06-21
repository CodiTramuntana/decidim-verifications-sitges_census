# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'decidim/verifications/sitges_census/version'

Gem::Specification.new do |s|
  s.version = Decidim::Verifications::SitgesCensus.version
  s.authors = ['Isaac Massot']
  s.email = ['isaac.mg@coditramuntana.com']
  s.license = 'AGPL-3.0'
  s.homepage = 'https://github.com/decidim/decidim-verifications-sitges_census'
  s.required_ruby_version = '>= 2.5.3'

  s.name = 'decidim-verifications-sitges_census'
  s.summary = 'A decidim verifications sitges census module'
  s.description = 'Decidim Verification for Sitges Census.'

  s.files = Dir['{app,config,lib}/**/*', 'LICENSE-AGPLv3.txt', 'Rakefile', 'README.md']

  DECIDIM_VERSION = ">= 0.17.1"

  s.add_dependency 'decidim-core', DECIDIM_VERSION
  s.add_dependency 'decidim-verifications', DECIDIM_VERSION
  s.add_dependency 'rails', '>= 5.2'
  s.add_dependency 'virtus-multiparams'

  s.add_development_dependency 'decidim-dev', DECIDIM_VERSION
end
