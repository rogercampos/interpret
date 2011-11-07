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
    it "should be able to import a file" do
      visit interpret_tools_path(:en)
      path = create_tmp_file("""
                             en:
                               someky: somevalue
                             """)
      page.attach_file("file", path)
      page.click_button "Upload"
      page.should have_content("Import successfully done.")
    end

    it "should not allow to be used with another language" do
      path = create_tmp_file("""
                             it:
                               someky: somevalue
                             """)
      visit interpret_tools_path(:en)
      page.attach_file("file", path)
      page.click_button "Upload"
      page.should have_content("the language doesn't match")
    end

    it "should update existing translations" do
      path = create_tmp_file(import_en_yml)
      visit interpret_tools_path(:en)

      page.attach_file("file", path)
      page.click_button "Upload"

      visit interpret_root_path(:en)
      within("table#results tbody tr:nth-child(4)") do
        page.should have_content("A new printer phrase")
      end
    end

    it "should create non existant translations" do
      path = create_tmp_file(import_en_yml)
      visit interpret_tools_path(:en)

      page.attach_file("file", path)
      page.click_button "Upload"

      visit interpret_root_path(:en)
      page.should have_content("new_stuff")
      page.should have_content("Something brand new")
    end
  end
end
