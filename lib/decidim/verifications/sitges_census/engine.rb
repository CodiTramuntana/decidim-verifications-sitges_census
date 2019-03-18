# frozen_string_literal: true

require 'rails'
require 'decidim/core'
require 'decidim/verifications'
require 'virtus/multiparams'

module Decidim
  module Verifications
    module SitgesCensus
      # This is the engine that runs on the public interface of decidim-verifications-sitges_census.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::SitgesCensus

        initializer 'decidim-verifications-sitges_census.assets' do |app|
          app.config.assets.precompile += %w[decidim-verifications-sitges_census_manifest.js decidim-verifications-sitges_census_manifest.css]
        end
      end
    end
  end
end
