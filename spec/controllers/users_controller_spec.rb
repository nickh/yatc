require 'spec_helper'

describe UsersController do
  render_views

  describe 'GET #index' do
    context 'for non-signed-in users' do
      it 'denies access' do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end

    context 'for sign-in users' do
      before(:each) do
        @users  = [test_sign_in(Factory(:user))]
        @users << Factory(:user, :email => 'another@example.com')
        @users << Factory(:user, :email => 'another@example.net')
        30.times do
          @users << Factory(:user, :email => Factory.next(:email))
        end
      end

      it 'succeeds' do
        get :index
        response.should be_success
      end

      it 'has the right title' do
        get :index
        response.should have_selector('title', :content => 'All Users')
      end

      it 'has an element for each user' do
        get :index
        @users[0..2].each do |user|
          response.should have_selector('li', :content => user.name)
        end
      end

      it 'paginates users' do
        get :index
        response.should have_selector('div.pagination')
        response.should have_selector('span.disabled', :content => 'Previous')
        response.should have_selector('a', :href => '/users?page=2', :content => '2')
        response.should have_selector('a', :href => '/users?page=2', :content => 'Next')
      end
    end
  end

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

  describe "GET 'edit'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
      get :edit, :id => @user
    end

    it 'succeeds' do
      response.should be_success
    end

    it 'has the right title' do
      response.should have_selector('title', :content => 'Edit user')
    end

    it 'has a link to change the Gravatar' do
      gravatar_url = 'http://gravatar.com/emails'
      response.should have_selector('a', :href => gravatar_url, :content => 'change')
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    context 'failure' do
      before(:each) do
        @invalid_user_attrs = {:name => '', :email => ''}
      end

      it "renders the 'edit' page" do
        put :update, :id => @user, :user => @invalid_user_attrs
        response.should render_template('edit')
      end

      it 'has the right title' do
        put :update, :id => @user, :user => @invalid_user_attrs
        response.should have_selector('title', :content => 'Edit user')
      end
    end

    context 'success' do
      before(:each) do
        @valid_user_attrs = {
          :name                  => 'New Name',
          :email                 => 'user@example.org',
          :password              => 'barbaz',
          :password_confirmation => 'barbaz',
        }
      end

      it "changes the user's attributes" do
        put :update, :id => @user, :user => @valid_user_attrs
        user = assigns(:user)
        @user.reload
        @user.name.should  == user.name
        @user.email.should == user.email
      end

      it 'redirects to the user show page' do
        put :update, :id => @user, :user => @valid_user_attrs
        response.should redirect_to(user_path(@user))
      end

      it 'has a flash message' do
        put :update, :id => @user, :user => @valid_user_attrs
        flash[:success].should =~ /updated/
      end
    end
  end

  describe 'authentication of edit/update pages' do
    before(:each) do
      @user = Factory(:user)
    end

    context 'for non-signed-in users' do
      it "denies access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end

      it "denies access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
    end

    context 'for signed-in users' do
      before(:each) do
        wrong_user = Factory(:user, :email => 'user@example.net')
        test_sign_in(wrong_user)
      end

      it 'requires matching users for #edit' do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it 'requires matching users for #update' do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end
end
