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

  it "should return the correct results searching by key" do
    visit interpret_search_path(:es)
    fill_in "Key value", :with => "printer"
    click_button "SEARCH"

    page.all("table#results tbody tr").size.should == 2
    within("table#results") do
      page.should have_content("Para imprimir")
      page.should have_content("Otra impresora")
    end
  end

  it "should not return blacklisted translations by key" do
    visit interpret_search_path(:es)
    fill_in "Key value", :with => "black_p1"
    click_button "SEARCH"

    page.all("table#results tbody tr").size.should == 0
  end

  it "should not return blacklisted translations by text" do
    visit interpret_search_path(:es)
    fill_in "Translation text", :with => "Una frase prohibida"
    click_button "SEARCH"

    page.all("table#results tbody tr").size.should == 0
  end

  it "should say the number of results found" do
    visit interpret_search_path(:es)
    fill_in "Key value", :with => "printer"
    click_button "SEARCH"

    within("#sidebar") do
      page.should have_content("2 results found")
    end
  end

  it "should be able to switch the language after a search" do
    visit interpret_search_path(:es)
    fill_in "Key value", :with => "printer"
    click_button "SEARCH"

    within("#languages_nav") { click_link "en" }
    page.all("table#results tbody tr").size.should == 2
  end

  it "should see the search results in the same order after switching languages" do
    visit interpret_search_path(:es)
    fill_in "Key value", :with => "printer"
    click_button "SEARCH"
    res = page.all("table#results tbody tr").map{|x| x.find("td.key").text}
    res.should == ["printer", "section1.printer"]

    within("#languages_nav") { click_link "en" }
    res = page.all("table#results tbody tr").map{|x| x.find("td.key").text}
    res.should == ["printer", "section1.printer"]
  end
end
