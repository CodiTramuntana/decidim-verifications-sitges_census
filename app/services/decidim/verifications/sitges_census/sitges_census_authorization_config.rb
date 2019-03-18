# frozen_string_literal: true

module Decidim
  module Verifications
    module SitgesCensus
      # This is a handler for SitgesCensus config values.
      # By now it only search for secret ones, but in future it could
      # be filled by a config record
      class SitgesCensusAuthorizationConfig
        class << self
          # Access URL for Sitges Census
          def url
            Rails.application.secrets.sitges_census[:sitges_census_url]
          end

          # secret value for Sitges Census to encrypt an unique_id
          def secret
            Rails.application.secrets.sitges_census[:sitges_census_secret]
          end
        end
      end
    end
  end
end
