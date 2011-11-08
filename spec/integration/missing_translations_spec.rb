# encoding: utf-8
require "spec_helper"

describe "Missing translations" do
  before(:all) { User.create!  }
  before { load_integration_data }

  it "should show me nothing when I'm in english language" do
    visit missing_translations_path(:en)
    page.should have_content("There can't be missing translations for the main language")
  end

  it "should show the total number of missing translations" do
    visit missing_translations_path(:es)
    page.should have_content("There are 2 missing translations in [es]")
  end

  it "should show me a table with all missing translations" do
    visit missing_translations_path(:es)
    elements = page.all("table#missing_translations tbody tr")
    elements.size.should == 2
    elements.first.should have_content("missings.p1")
  end

  it "should show me the value in english for a given key" do
    visit missing_translations_path(:es)
    page.should have_content("Missing one")
  end

  it "should let me create a new translation in the current language" do
    visit missing_translations_path(:es)

    within("table#missing_translations tbody tr:first") do
      page.fill_in "translation_value", :with => "Uno perdido"
      page.click_button "Create"
    end

    page.should have_content("New translation created for missings.p1")
    page.all("table#missing_translations tbody tr").size.should == 1
    page.should have_content("Missing two")
  end

  it "should let me destroy the original translation" do
    visit missing_translations_path(:es)

    within("table#missing_translations tbody tr:first") do
      page.click_link "Destroy"
    end

    page.should have_content("Translation missings.p1 destroyed")
    page.all("table#missing_translations tbody tr").size.should == 1
    page.should have_content("Missing two")
  end

  it "should not show me blacklisted translations" do
    visit missing_translations_path(:es)
    page.should have_no_content("missings.black")
    elements = page.all("table#missing_translations tbody tr")
    elements.size.should == 2
  end
end
