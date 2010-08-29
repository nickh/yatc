require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'show'" do
    before(:each) do
      @user = Factory(:user)
      get :show, :id => @user
    end

    it 'succeeds' do
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
    it "succeeds" do
      get 'new'
      response.should be_success
    end

    it 'has the right title' do
      get 'new'
      response.should have_selector('title', :content => 'Sign Up')
    end
  end

  describe "POST 'create'" do
    describe 'failure' do
      before(:each) do
        @user_attr = {:name => '', :email => '', :password => '', :password_confirmation => ''}
      end

      it 'does not create a user' do
        lambda do
          post :create, :user => @user_attrs
        end.should_not change(User, :count)
      end

      it 'has the right title' do
        post :create, :user => @user_attrs
        response.should have_selector('title', :content => 'Sign Up')
      end

      it "renders the 'new' page" do
        post :create, :user => @user_attrs
        response.should render_template('new')
      end
    end

    describe 'success' do
      before(:each) do
        @user_attrs = {
          :name                  => 'New User',
          :email                 => 'user@example.com',
          :password              => 'foobar',
          :password_confirmation => 'foobar'
        }
      end

      it 'creates a user' do
        lambda do
          post :create, :user => @user_attrs
        end.should change(User, :count).by(1)
      end

      it 'redirects to the user show page' do
        post :create, :user => @user_attrs
        response.should redirect_to(user_path(assigns(:user)))
      end

      it 'has a welcome message' do
        post :create, :user => @user_attrs
        flash[:success].should =~ /welcome to the sample app/i
      end

      it 'signs the user in' do
        post :create, :user => @user_attrs
        controller.should be_signed_in
      end
    end
  end
end
