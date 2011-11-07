# encoding: utf-8
require "spec_helper"

describe "Translations" do
  before(:all) { User.create!  }
  before { load_integration_data }

  it "should let me edit a translation", :js => true do
    visit interpret_root_path(:en)

    # We need this to identify the translation we want to change
    bip_id = ""
    within("table#results tbody tr:first") do
      bip_id = page.all("span.best_in_place").first[:id]
    end
    bip_id = bip_id.scan(/translation_\d+/).first

    bip_area bip_id, :value, "New value"


    visit interpret_root_path(:en)
    within("table#results tbody tr:first") do
      page.should have_content("New value")
    end
  end
end
