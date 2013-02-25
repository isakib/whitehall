When /^I create a worldwide organisation "([^"]*)" sponsored by the "([^"]*)" with a summary, description and services$/ do |name, sponsoring_organisation|
  visit new_admin_worldwide_organisation_path
  fill_in "Name", with: name
  fill_in "Logo formatted name", with: name
  fill_in "Summary", with: "Worldwide organisation summary"
  fill_in "Description", with: "Worldwide **organisation** description"
  fill_in "Services", with: "## Passport renewals\n\nYou can renew your passport"
  select sponsoring_organisation, from: "Sponsoring organisations"
  click_on "Save"
end

When /^I create a new worldwide organisation "([^"]*)" in "([^"]*)"$/ do |name, location|
  visit new_admin_worldwide_organisation_path
  fill_in "Name", with: name
  fill_in "Logo formatted name", with: name
  fill_in "Summary", with: "Worldwide organisation summary"
  fill_in "Description", with: "Worldwide **organisation** description"
  select location, from: "World location"
  click_on "Save"
end

When /^I create a new worldwide organisation "([^"]*)" in  "([^"]*)" sponsored by the "([^"]*)"$/ do |name, location, sponsoring_organisation|
  visit new_admin_worldwide_organisation_path
  fill_in "Name", with: name
  fill_in "Logo formatted name", with: name
  fill_in "Summary", with: "Worldwide organisation summary"
  fill_in "Description", with: "Worldwide **organisation** description"
  select location, from: "World location"
  select sponsoring_organisation, from: "Sponsoring organisations"
  click_on "Save"
end


Then /^I should see the(?: updated)? worldwide organisation information on the public website$/ do
  worldwide_organisation = WorldwideOrganisation.last
  visit worldwide_organisation_path(worldwide_organisation)
  assert page.has_content?(worldwide_organisation.logo_formatted_name)
  assert page.has_css?(".description strong", text: "organisation")
  assert page.has_css?("#our-services h2", text: 'Passport renewals')
end

Then /^the "([^"]*)" logo should show correctly with the HMG crest$/ do |name|
  worldwide_organisation = WorldwideOrganisation.find_by_name(name)
  assert page.has_css?(".organisation-logo-stacked-single-identity", text: worldwide_organisation.logo_formatted_name)
end

Then /^I should see that it is part of the "([^"]*)"$/ do |sponsoring_organisation|
  assert page.has_css?(".sponsoring-organisation", sponsoring_organisation)
end

Then /^I should see the worldwide organisation listed on the page$/ do
  worldwide_organisation = WorldwideOrganisation.last
  within record_css_selector(worldwide_organisation) do
    assert page.has_content?(worldwide_organisation.name)
  end
end

Then /^I should see the worldwide organisation "([^"]*)" on the "([^"]*)" world location page$/ do |worldwide_organisation_name, location_name|
  location = WorldLocation.find_by_name(location_name)
  worldwide_organisation = WorldwideOrganisation.find_by_name(worldwide_organisation_name)
  visit world_location_path(location)
  within record_css_selector(worldwide_organisation) do
    assert page.has_content?(worldwide_organisation_name)
  end
end

When /^I update the worldwide organisation to set the name to "([^"]*)"$/ do |new_title|
  visit edit_admin_worldwide_organisation_path(WorldwideOrganisation.last)
  fill_in "Name", with: new_title
  click_on "Save"
end

When /^I delete the worldwide organisation$/ do
  @worldwide_organisation = WorldwideOrganisation.last
  visit edit_admin_worldwide_organisation_path(@worldwide_organisation)
  click_on "delete"
end

Then /^the worldwide organisation should not be visible from the public website$/ do
  assert_raises(ActiveRecord::RecordNotFound) do
    visit worldwide_organisation_path(@worldwide_organisation)
  end
end

Given /^a worldwide organisation "([^"]*)"$/ do |name|
  create(:worldwide_organisation, name: name)
end

Given /^a worldwide organisation "([^"]*)" exists for the country "([^"]*)" with translations into "([^"]*)"$/ do |name, country_name, translation|
  country = create(:country, translated_into: [translation])
  create(:worldwide_organisation, name: name, world_locations: [country])
end

When /^I add a "([^"]*)" social media link "([^"]*)"$/ do |social_service, url|
  visit admin_worldwide_organisation_path(WorldwideOrganisation.last)
  click_link "Social Media Accounts"
  click_link "Add"
  select social_service, from: "Service"
  fill_in "Url", with: url
  click_on "Save"
end

Then /^the social link should be shown on the public website$/ do
  visit worldwide_organisation_path(WorldwideOrganisation.last)
  assert page.has_css?(".social-media-accounts")
end

When /^I add an "([^"]*)" office with address, phone number, and some services$/ do |description|
  service1 = create(:worldwide_service, name: 'Dance lessons')
  service2 = create(:worldwide_service, name: 'Courses in advanced sword fighting')
  service3 = create(:worldwide_service, name: 'Beard grooming')

  visit offices_admin_worldwide_organisation_path(WorldwideOrganisation.last)
  click_link "Add"
  fill_in "Title", with: description

  check service1.name
  check service3.name

  fill_in "Street address", with: "address1\naddress2"
  fill_in "Postal code", with: "12345-123"
  fill_in "Email", with: "foo@bar.com"
  fill_in "Label", with: "Main phone number"
  fill_in "Number", with: "+22 (0) 111 111-111"
  select "United Kingdom", from: "Country"
  click_on "Save"
end

Then /^the "([^"]*)" office details should be shown on the public website$/ do |description|
  worldwide_org = WorldwideOrganisation.last
  visit worldwide_organisation_path(worldwide_org)
  worldwide_office = worldwide_org.offices.includes(:contact).where(contacts: {title: description}).first

  within '.contact' do
    assert page.has_css?("h2", text: worldwide_office.contact.title)
    assert page.has_css?('.vcard', text: worldwide_office.contact.street_address)
    assert page.has_css?('.tel', text: worldwide_office.contact.contact_numbers.first.number)
  end
end

Given /^that the world location "([^"]*)" exists$/ do |country_name|
  create(:country, name: country_name)
end

Given /^the worldwide organisation "([^"]*)" exists$/ do |worldwide_organisation_name|
  create(:worldwide_organisation, name: worldwide_organisation_name, logo_formatted_name: worldwide_organisation_name)
end

When /^I begin editing a new worldwide organisation "([^"]*)"$/ do |worldwide_organisation_name|
  visit new_admin_worldwide_organisation_path
  fill_in "Name", with: worldwide_organisation_name
  fill_in "Summary", with: "Worldwide organisation summary"
  fill_in "Description", with: "Worldwide **organisation** description"
end

When /^I select world location "([^"]*)"$/ do |world_location_name|
  select world_location_name, from: "World location"
end

When /^I click save$/ do
  click_on "Save"
end

Given /^a worldwide organisation "([^"]*)" with offices "([^"]*)" and "([^"]*)"$/ do |worldwide_organisation_name, contact1_title, contact2_title|
  worldwide_organisation = create(:worldwide_organisation, name: worldwide_organisation_name)
  create(:worldwide_office, worldwide_organisation: worldwide_organisation, contact: create(:contact, title: contact1_title))
  create(:worldwide_office, worldwide_organisation: worldwide_organisation, contact: create(:contact, title: contact2_title))
end

When /^I choose "([^"]*)" to be the main office$/ do |contact_title|
  worldwide_office = WorldwideOffice.includes(:contact).where(contacts: {title: contact_title}).first
  visit admin_worldwide_organisation_path(WorldwideOrganisation.last)
  click_link "Offices"
  within record_css_selector(worldwide_office) do
    click_button 'Set as main office'
  end
end

Then /^the "([^"]*)" should be shown as the main office on the public website$/ do |contact_title|
  worldwide_organisation = WorldwideOrganisation.last
  worldwide_office = WorldwideOffice.includes(:contact).where(contacts: {title: contact_title}).first
  visit worldwide_organisation_path(worldwide_organisation)
  within "#{record_css_selector(worldwide_office)}.main" do
    assert page.has_content?(contact_title)
  end
end

Then /^he is listed as the supporting position of "([^"]*)" on the worldwide organisation page$/ do |position_name|
  worldwide_organisation = WorldwideOrganisation.last
  person = Person.last
  visit worldwide_organisation_path(worldwide_organisation)
  within record_css_selector(person) do
    assert page.has_content?(person.name)
    assert page.has_css?('p.role', text: position_name)
  end
end

Then /^I should see his picture on the worldwide organisation page$/ do
  visit worldwide_organisation_path(WorldwideOrganisation.last)
  person = Person.last

  within record_css_selector(person) do
    assert page.has_css?('img')
  end
end

Then /^I should not see his picture on the worldwide organisation page$/ do
  visit worldwide_organisation_path(WorldwideOrganisation.last)
  person = Person.last

  within record_css_selector(person) do
    refute page.has_css?('img')
  end
end

def add_translation_to_worldwide_organisation(worldwide_organisation, translation)
  translation = translation.stringify_keys
  visit admin_worldwide_organisations_path
  within record_css_selector(worldwide_organisation) do
    click_link "Manage translations"
  end

  select translation["locale"], from: "Locale"
  click_on "Create translation"
  fill_in "Name", with: translation["name"]
  fill_in "Summary", with: translation["summary"]
  fill_in "Description", with: translation["description"]
  fill_in "Services", with: translation["services"]
  click_on "Save"
end

def edit_translation_for_worldwide_organisation(locale, name, translation)
  location = WorldwideOrganisation.find_by_name!(name)
  visit admin_worldwide_organisations_path
  within record_css_selector(location) do
    click_link "Manage translations"
  end
  click_link locale
  fill_in "Name", with: translation["name"]
  fill_in "Summary", with: translation["summary"]
  fill_in "Description", with: translation["description"]
  fill_in "Services", with: translation["services"]
  click_on "Save"
end

When /^I add a new translation to the worldwide organisation "([^"]*)" with:$/ do |name, table|
  worldwide_organisation = WorldwideOrganisation.find_by_name!(name)
  add_translation_to_worldwide_organisation(worldwide_organisation, table.rows_hash)
end

Then /^when viewing the worldwide organisation "([^"]*)" with the locale "([^"]*)" I should see:$/ do |name, locale, table|
  worldwide_organisation = WorldwideOrganisation.find_by_name!(name)
  translation = table.rows_hash

  visit world_location_path(worldwide_organisation.world_locations.first, locale: locale)
  within record_css_selector(worldwide_organisation) do
    assert page.has_css?('.name', text: translation["name"]), "Name wasn't present on associated world location page"
  end

  # until links preserve locale, we cannot do this:
  #     click_link translation["name"]
  # so instead, we check the link is at least present with the right text, and then visit it with the right locale
  assert page.has_link?(translation["name"], href: worldwide_organisation_path(worldwide_organisation))
  visit worldwide_organisation_path(worldwide_organisation, locale: locale)

  assert page.has_css?('.summary', text: translation["summary"]), "Summary wasn't present"
  assert page.has_css?('.description', text: translation["description"]), "Description wasn't present"
  assert page.has_css?('.content', text: translation["services"]), "Services wasn't present"
end

Given /^a worldwide organisation "([^"]*)" exists with a translation for the locale "([^"]*)"$/ do |name, native_locale_name|
  locale_code = Locale.find(native_locale_name).code
  country = create(:world_location, world_location_type: WorldLocationType::Country, translated_into: [locale_code])
  create(:worldwide_organisation, name: name, world_locations: [country], translated_into: [locale_code])
end

When /^I edit the "([^"]*)" translation for the worldwide organisation "([^"]*)" setting:$/ do |locale, name, table|
  edit_translation_for_worldwide_organisation(locale, name, table.rows_hash)
end