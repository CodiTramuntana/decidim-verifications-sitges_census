# frozen_string_literal: true

require "spec_helper"

describe "Authorizations", type: :system, perform_enqueued: true, with_authorization_workflows: ["sitges_census_authorization_handler"] do
  let(:organization) do
    create(
      :organization,
      name: "Ajuntament",
      default_locale: :ca,
      available_locales: [:es, :ca, :en],
      available_authorizations: authorizations
    )
  end

  let(:authorizations) { ["sitges_census_authorization_handler"] }
  let!(:scope) { create :scope, organization: organization, code: "1" }

  let!(:valid_sitges_census) do
    {
      document_number: 'X0000000F',
      birthdate: Date.new(1973, 1, 18)
    }
  end

  let!(:invalid_sitges_census) do
    {
      document_number: '',
      birthdate: Date.today
    }
  end

  let(:ws_response) do
    Nokogiri::XML("<CodiResultat>000</CodiResultat>").remove_namespaces!
  end

  # Selects a birth date that will not cause errors in the form: January 12, 1979.
  def fill_in_authorization_form
    fill_in "authorization_handler_document_number", with: "12345678A"
    fill_in "authorization_handler_birthdate", with: "04/08/1899"
  end

  before do
    allow_any_instance_of(Decidim::Verifications::SitgesCensus::SitgesCensusAuthorizationHandler).to receive(:ws_response).and_return(ws_response)
    switch_to_host(organization.host)
  end

  context "user account" do
    let(:user) { create(:user, :confirmed, organization: organization) }

    before do
      login_as user, scope: :user
      visit decidim.root_path
    end

    it "allows the user to authorize against available authorizations", sitges_census_stub_type: :valid do
      within_user_menu do
        click_link "El meu compte"
      end

      click_link "Autoritzacions"
      click_link "Ciutadà de Sitges"

      fill_in_authorization_form
      click_button "Enviar"

      expect(page).to have_content("amb èxit")

      visit decidim_verifications.authorizations_path

      within ".authorizations-list" do
        expect(page).to have_content("Ciutadà de Sitges")
        expect(page).not_to have_link("Ciutadà de Sitges")
      end
    end

    context "when the user has already been authorised" do
      let!(:authorization) do
        create(:authorization,
               name: Decidim::Verifications::SitgesCensus::SitgesCensusAuthorizationHandler.handler_name,
               user: user)
      end

      it "shows the authorization at their account" do
        visit decidim_verifications.authorizations_path

        within ".authorizations-list" do
          expect(page).to have_content("Ciutadà de Sitges")
          expect(page).not_to have_link("Ciutadà de Sitges")
          expect(page).to have_content(I18n.localize(authorization.granted_at, format: :long, locale: :ca))
        end
      end
    end

    context "when data is not valid" do
      before do
        visit decidim_verifications.new_authorization_path(handler: "sitges_census_authorization_handler")
      end

      it 'shows an error' do
        submit_sitges_census_form(
          document_number: invalid_sitges_census[:document_number],
          birthdate: invalid_sitges_census[:birthdate]
        )
        expect(page).to have_content("Hi ha un error en aquest camp")

        submit_sitges_census_form(
          document_number: valid_sitges_census[:document_number],
          birthdate: invalid_sitges_census[:birthdate]
        )
        expect(page).to have_content('Heu de tenir almenys 16 anys')
      end

      it 'shows an error when data is not valid in Sitges Census', sitges_census_stub_type: :invalid do
        submit_sitges_census_form(
          document_number: valid_sitges_census[:document_number],
          birthdate: valid_sitges_census[:birthdate]
        )

        expect(page).to have_content('Alguna cosa ha anat malament. Si us plau, intenti-ho més tard')
      end

      it 'does not submit when data is not fulfilled' do
        submit_sitges_census_form(
          document_number: '',
          birthdate: ''
        )

        expect(page).to have_current_path decidim_verifications.new_authorization_path(handler: "sitges_census_authorization_handler")
      end
    end

    private

     def submit_sitges_census_form(document_number:, birthdate:)
       fill_in "Document d'identitat", with: document_number
       fill_in 'Data de naixement', with: birthdate

       click_button 'Enviar'
     end
  end
end
