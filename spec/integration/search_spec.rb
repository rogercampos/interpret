# encoding: utf-8
require "spec_helper"

describe "Search" do
  before(:all) { User.create!  }
  before { load_integration_data }

  it "should return the correct results searching by text" do
    visit interpret_search_path(:es)
    fill_in "Translation text", :with => "Comentarios"
    click_button "SEARCH"

    page.all("table#results tbody tr").size.should == 1
    within("table#results") do
      page.should have_content("Comentarios")
    end
  end

  it "should work with accents and other non ascii chars" do
    visit interpret_search_path(:es)
    fill_in "Translation text", :with => "extraña"
    click_button "SEARCH"

    page.all("table#results tbody tr").size.should == 1
    within("table#results") do
      page.should have_content("extraña")
    end
  end

  it "should return the correct results searching by key"
  it "should not return blacklisted translations"
  it "should say the number of results found"
  it "should be able to switch the language after a search"
  it "should see the search results in the same order after switching languages"
end
