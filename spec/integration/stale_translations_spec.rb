# encoding: utf-8
require "spec_helper"

describe "Stale translations" do
  before(:all) { User.create!  }
  before { load_integration_data }

  it "should show me nothing when I'm in english language" do
    visit interpret_stale_translations_path(:en)
    page.should have_content("There can't be stale translations for the main language")
  end

  it "should show me the recently modified translations in english", :js => true do
    visit interpret_root_path(:en)
    change_translation("table#results tbody tr:first", "New comments text")

    visit interpret_stale_translations_path(:es)
    page.all("table#stale_translations tbody tr").size.should == 1
  end

  it "should not show anything if I update a 'es' translation", :js => true do
    visit interpret_root_path(:es)
    change_translation("table#results tbody tr:first", "New comments text")

    visit interpret_stale_translations_path(:es)
    page.all("table#stale_translations tbody tr").size.should == 0
  end
end
