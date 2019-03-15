# frozen_string_literal: true

require 'digest'
module Decidim
  module Verifications
    module SitgesCensus
      # Checks the authorization against the census of Sitges to create authorizations.
      # This AuthorizationHandler uses the Sitges census WS to VALIDATE
      # if user is a customer or not.
      #
      # To send a request you MUST provide:
      # - document_number: A String with the user document_number.
      # - birthdate: A String must be in a YYYYMMDD format
      class SitgesCensusAuthorizationHandler < Decidim::AuthorizationHandler

        attribute :document_number, String
        attribute :birthdate, Decidim::Attributes::LocalizedDate

        validates :document_number, presence: true
        validates :birthdate, presence: true

        validates :document_number, format: { with: /\A[A-z0-9]*\z/ }, presence: true

        validate :check_legal_age
        validate :in_sitges_census?

        def unique_id
          Digest::SHA512.hexdigest(
            "#{document_number}-#{Decidim::Verifications::SitgesCensus::SitgesCensusAuthorizationConfig.secret}"
          )
        end

        private

        # Checks for birthdate greater or equal than 16 years. For fewer years, it adds
        # and error to form object
        #
        # Returns nothing
        def check_legal_age
          return unless age_from_birthdate
          if age_from_birthdate < 16
            errors.add(:birthdate, I18n.t('errors.messages.sitges_census_authorization_handler.too_young'))
          end
        end

        # Calculate age using birthdate
        #
        # Returns age as Integer
        def age_from_birthdate
          return @age unless self.birthdate.presence
          @age ||= ((Time.now - self.birthdate.to_time) / 1.years).floor
        end

        # Checks the response of SitgesCensus WS, and add errors in bad cases
        #
        # Returns a boolean
        def in_sitges_census?
          return false if errors.any? || uncomplete_credentials?

          unless already_processed?
            invoke_census_ws_for_validation
          end

          if success_response?
            # "SI", "000", "DNI i Data de naixement correctes"
            unless response_code == "000"
              case response_code
              when "901"
                # "NO", "901", "DNI no informat"
                errors.add(:document_number, I18n.t('errors.messages.sitges_census_authorization_handler.document_number_not_valid'))
              when "902"
                # "NO", "902", "Data de naixement no informada"
                errors.add(:birthdate, I18n.t('errors.messages.sitges_census_authorization_handler.birthdate_not_valid'))
              when "903"
                # "NO", "903", "DNI inccorrecte"
                errors.add(:document_number, I18n.t('errors.messages.sitges_census_authorization_handler.incorrect_document_number'))
              when "904"
                # "NO", "904", "DNI i Data de Naixement no es corresponen"
                errors.add(:birthdate, I18n.t('errors.messages.sitges_census_authorization_handler.document_number_and_birthdate_dont_correspond'))
              when "997"
                # "NO", "997", "Accés al servei web permés"
                errors.add(:base, I18n.t('errors.messages.sitges_census_authorization_handler.webservice_access_permit'))
              when "998"
                # "NO", "998", "Operació no permessa"
                errors.add(:base, I18n.t('errors.messages.sitges_census_authorization_handler.operation_not_valid'))
              else
                # "NO", "999", "Error indeterminat"
                errors.add(:base, I18n.t('errors.messages.sitges_census_authorization_handler.unexpected_error'))
              end
            end
          else
            errors.add(:base, I18n.t('errors.messages.sitges_census_authorization_handler.cannot_validate'))
          end
          errors.empty?
        end

        # Check for WS needed values
        #
        # Returns a boolean
        def uncomplete_credentials?
          sanitize_document_number.blank? || sanitize_birthdate.blank?
        end

        # Document number parameter, as String
        #
        # Returns a String
        def sanitize_document_number
          @sanitize_document_number ||= document_number&.to_s
        end

        # Birthdate must be in a YYYYMMDD format
        #
        # Returns a String
        def sanitize_birthdate
          @sanitize_birthdate ||= birthdate&.strftime('%Y%m%d')
        end

        def form_data_attributes
          {
            a_strDocument: sanitize_document_number,
            a_strDataNaixement: sanitize_birthdate
          }
        end

        # Check the error code of body response
        #
        # Returns an Integer
        def response_code
          return nil if @response.blank?
          @response[:body].xpath("//CodiResultat").text
        end

        def invoke_census_ws_for_validation
          begin
            ws_response = Faraday.get do |request|
              request.url(Decidim::Verifications::SitgesCensus::SitgesCensusAuthorizationConfig.url)
              request.params =  form_data_attributes
            end
            @response = { body: Nokogiri::XML(ws_response.body).remove_namespaces!, status: ws_response.status }
          rescue Faraday::ConnectionFailed
            errors.add(:base, I18n.t('errors.messages.sitges_census_authorization_handler.connection_failed'))
          rescue Faraday::TimeoutError
            errors.add(:base, I18n.t('errors.messages.sitges_census_authorization_handler.connection_timeout'))
          end
        end

        # Check if request had benn already been processed and saved
        #
        # Returns a boolean
        def already_processed?
          defined?(@response)
        end

        # Check if request had been correctly performed
        #
        # Returns a boolean
        def success_response?
          # Status code 200, success request. Otherwise, error
          @response[:status] == 200
        end
      end
    end
  end
end
