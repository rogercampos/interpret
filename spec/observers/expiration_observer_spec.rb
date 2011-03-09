# encoding: utf-8
require 'spec_helper'

describe Interpret::ExpirationObserver do

  before do
    Interpret::Translation.delete_all
  end

  it "should call run_expiration on observer" do
    backend = mock("A backend")
    backend.should_receive(:"reload!").once
    Interpret.backend = backend
    Interpret::Translation.create! :locale => "en", :key => "en.hello", :value => "Hello world"
  end
end

