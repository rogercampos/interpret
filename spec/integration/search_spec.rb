# encoding: utf-8
require "spec_helper"

describe "Search" do
  before(:all) { User.create!  }
  before { load_integration_data }

  describe "search by text" do
    it "should return the correct results" do
      visit interpret_search_path(:es)
      fill_in "Translation text", :with => "Comentarios"
      click_button "SEARCH"

      page.all("table#results tbody tr").size.should == 1
      within("table#results") do
        page.should have_content("Comentarios")
      end
    end

    it "should work with accents and other non ascii chars"
    it "should not return any result"
  end
end
