require 'spec_helper'

describe PagesController do
  render_views

  before(:each) do
    @base_title = 'Ruby on Rails Tutorial Sample App | '
  end

  describe "GET 'home'" do
    it "succeeds" do
      get 'home'
      response.should be_success
    end

    it "has the right title" do
      get 'home'
      response.should have_selector('title', :content => @base_title + 'Home')
    end
  end

  describe "GET 'contact'" do
    it "succeeds" do
      get 'contact'
      response.should be_success
    end

    it "has the right title" do
      get 'contact'
      response.should have_selector('title', :content => @base_title + 'Contact')
    end
  end

  describe "GET 'about'" do
    it "succeeds" do
      get 'about'
      response.should be_success
    end

    it "has the right title" do
      get 'about'
      response.should have_selector('title', :content => @base_title + 'About')
    end
  end

  describe "GET 'help'" do
    it "succeeds" do
      get 'help'
      response.should be_success
    end

    it "has the right title" do
      get 'help'
      response.should have_selector('title', :content => @base_title + 'Help')
    end
  end

end
