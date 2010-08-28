require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'show'" do
    before(:each) do
      @user = Factory(:user)
      get :show, :id => @user
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'finds the right user' do
      assigns(:user).should == @user
    end

    it 'has the right title' do
      response.should have_selector('title', :content => @user.name)
    end

    it 'includes the user name' do
      response.should have_selector('h1', :content => @user.name)
    end

    it 'has a profile image' do
      response.should have_selector('h1>img', :class => 'gravatar')
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end

    it 'has the right title' do
      get 'new'
      response.should have_selector('title', :content => 'Sign Up')
    end
  end

end
