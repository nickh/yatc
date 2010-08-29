require 'spec_helper'

describe "LayoutLinks" do
  it "has a Home page at '/'" do
    get '/'
    response.should have_selector('title', :content => 'Home')
  end

  it "has a Contact page at '/contact'" do
    get '/contact'
    response.should have_selector('title', :content => 'Contact')
  end

  it "has a About page at '/about'" do
    get '/about'
    response.should have_selector('title', :content => 'About')
  end

  it "has a Help page at '/help'" do
    get '/help'
    response.should have_selector('title', :content => 'Help')
  end

  it "has a signup page at '/signup'" do
    get '/signup'
    response.should have_selector('title', :content => 'Sign Up')
  end

  it "has the right links on the layout" do
    visit root_path
    click_link 'About'
    response.should have_selector('title', :content => 'About')
    click_link 'Help'
    response.should have_selector('title', :content => 'Help')
    click_link 'Contact'
    response.should have_selector('title', :content => 'Contact')
    click_link 'Home'
    response.should have_selector('title', :content => 'Home')
    click_link 'Sign up now!'
    response.should have_selector('title', :content => 'Sign Up')
  end

  context 'when not signed in' do
    it 'has a signin link' do
      visit root_path
      response.should have_selector('a', :href => signin_path, :content => 'Sign in')
    end
  end

  context 'when signed in' do
    before(:each) do
      @user = Factory(:user)
      integration_sign_in @user
      visit root_path
    end

    it 'has a signout link' do
      response.should have_selector('a', :href => signout_path, :content => 'Sign out')
    end

    it 'has a profile link' do
      response.should have_selector('a', :href => user_path(@user), :content => 'Profile')
    end
  end
end
