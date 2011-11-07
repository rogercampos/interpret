# encoding: utf-8
require "spec_helper"

describe "Tools" do
  before(:all) { User.create!  }
  before { load_integration_data }

  describe "Download" do
    it "should be able to download a .yml file for the current language" do
      visit interpret_tools_path(:en)
      page.should have_button("Download")

      page.click_button "Download"
      page.response_headers["Content-Type"].should == "text/plain"
    end

    it "should get a yaml file for the current language" do
      visit interpret_tools_path(:en)
      page.should have_button("Download")

      page.click_button "Download"
      hash = YAML.load(page.source)
      hash.first.first.should == "en"
    end

    it "should get a yaml file with all the correct translations" do
      visit interpret_tools_path(:en)
      page.should have_button("Download")

      page.click_button "Download"
      hash = YAML.load(page.source)
      source_hash = YAML.load(en_yml)

      hash.sort.should == source_hash.sort
    end
  end

  describe "Import" do
    pending
  end
end
