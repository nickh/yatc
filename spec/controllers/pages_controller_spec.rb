require 'spec_helper'

describe PagesController do
  render_views

  before(:each) do
    @base_title = 'Ruby on Rails Tutorial Sample App | '
  end

  describe 'GET #home' do
    it "succeeds" do
      get 'home'
      response.should be_success
    end

    it "has the right title" do
      get 'home'
      response.should have_selector('title', :content => @base_title + 'Home')
    end

    it 'wraps long words in microposts' do
      user = test_sign_in(Factory(:user))
      too_long_word = 'loremipsum'*13
      Factory(:micropost, :user => user, :content => too_long_word)
      get :home
      response.body.should =~ /loremipsum\s*&#8203;/
    end

    context 'for a signed-in user' do
      before(:each) do
        @user = test_sign_in(Factory(:user))
      end

      context 'with no microposts' do
        it 'displays the micropost count' do
          get :home
          response.should have_selector('span.microposts', :content => 'No microposts')
        end
      end

      context 'with one micropost' do
        it 'displays the micropost count' do
          Factory(:micropost, :user => @user)
          get :home
          response.should have_selector('span.microposts', :content => '1 micropost')
        end
      end

      context 'with more than one micropost' do
        it 'displays the micropost count' do
          2.times {|i| Factory(:micropost, :user => @user)}
          get :home
          response.should have_selector('span.microposts', :content => '2 microposts')
        end
      end

      context 'with followers/followings' do
        before(:each) do
          other_user = Factory(:user, :email => Factory.next(:email))
          other_user.follow!(@user)
        end

        it 'has the correct follower/following counts' do
          get :home
          response.should have_selector('a', :href => following_user_path(@user),
                                             :content => '0 following')
          response.should have_selector('a', :href => followers_user_path(@user),
                                             :content => '1 following')
        end
      end
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
