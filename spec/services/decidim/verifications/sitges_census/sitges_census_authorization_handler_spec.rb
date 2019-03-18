# coding: utf-8
# frozen_string_literal: true
require "spec_helper"
require 'digest'
require "decidim/dev/test/authorization_shared_examples"

module Decidim
  module Verifications
    module SitgesCensus
      describe SitgesCensusAuthorizationHandler do
        let(:subject) { handler }
        let(:handler) { described_class.from_params(params) }
        let(:document_number) { "12345678A" }
        let(:birthdate) { Date.civil(1987, 9, 17) }
        let(:user) { create :user }
        let(:params) do
          {
            user: user,
            document_number: document_number,
            birthdate: birthdate
          }
        end

        it_behaves_like "an authorization handler"

        describe "metadata" do
          subject { handler.metadata }

          it "should not be filled", sitges_census_stub_type: :valid do
             is_expected.to eq({})
          end
        end

        describe "with a valid user" do
          context "when no document number" do
            let(:document_number) { nil }

            it { is_expected.not_to be_valid }
          end

          context "with an invalid format" do
            let(:document_number) { "(╯°□°）╯︵ ┻━┻" }

            it { is_expected.not_to be_valid }
          end

          context "when no birthdate" do
            let(:birthdate) { nil }

            it { is_expected.not_to be_valid }
          end

          context "when birthdate is less than 16 years ago" do
            let(:birthdate) { 15.years.ago }

            it { is_expected.not_to be_valid }
          end

          context "when all data is valid", sitges_census_stub_type: :valid do
            it { is_expected.to be_valid }
          end

          context "unique_id" do
            it "generates a different ID for a different document number" do
              handler.document_number = "ABC123"
              unique_id1 = handler.unique_id

              handler.document_number = "XYZ456"
              unique_id2 = handler.unique_id

              expect(unique_id1).to_not eq(unique_id2)
            end

            it "generates the same ID for the same document number" do
              handler.document_number = "ABC123"
              unique_id1 = handler.unique_id

              handler.document_number = "ABC123"
              unique_id2 = handler.unique_id

              expect(unique_id1).to eq(unique_id2)
            end

            it "hashes the document number" do
              handler.document_number = "ABC123"
              unique_id = handler.unique_id

              expect(unique_id).to_not include(handler.document_number)
            end
          end
        end
      end
    end
  end
end
