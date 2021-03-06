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

  describe 'GET #show' do
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

    it "shows the user's microposts" do
      mp1 = Factory(:micropost, :user => @user, :content => 'Foo bar')
      mp2 = Factory(:micropost, :user => @user, :content => 'Foo bar')
      get :show, :id => @user
      response.should have_selector('span.content', :content => mp1.content)
      response.should have_selector('span.content', :content => mp2.content)
    end
  end

  describe "GET 'new'" do
    context 'as a non-signed-in user' do
      it "succeeds" do
        get 'new'
        response.should be_success
      end

      it 'has the right title' do
        get 'new'
        response.should have_selector('title', :content => 'Sign Up')
      end
    end

    context 'as a signed-in user' do
      before(:each) do
        test_sign_in(Factory(:user))
      end

      it 'redirects to the home page' do
        get 'new'
        response.should redirect_to(root_path)
      end
    end
  end

  describe "POST 'create'" do
    describe 'failure' do
      before(:each) do
        @user_attr = {:name => '', :email => '', :password => '', :password_confirmation => ''}
      end

      context 'as a non-signed-in user' do
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

      context 'as a signed-in user' do
        before(:each) do
          test_sign_in(Factory(:user))
        end

        it 'redirects to the home page' do
          post :create, :user => @user_attrs
          response.should redirect_to(root_path)
        end
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

      context 'as a non-signed-in user' do
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

      context 'as a signed-in user' do
        before(:each) do
          test_sign_in(Factory(:user))
        end

        it 'redirects to the home page' do
          post :create, :user => @user_attrs
          response.should redirect_to(root_path)
        end
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

  describe 'DELETE #destroy' do
    before(:each) do
      @user = Factory(:user)
    end

    context 'as a non-signed-in user' do
      it 'denies access' do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    context 'as a non-admin user' do
      it 'protects the page' do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end

    context 'as an admin user' do
      before(:each) do
        @admin = Factory(:user, :email => 'admin@example.com', :admin => true)
        test_sign_in(@admin)
      end

      context 'deleting another user' do
        it 'destroys the user' do
          lambda do
            delete :destroy, :id => @user
          end.should change(User, :count).by(-1)
        end

        it 'redirects to the users page' do
          delete :destroy, :id => @user
          response.should redirect_to(users_path)
        end
      end

      context 'deleting themselves' do
        it 'does not destroy the user' do
          delete :destroy, :id => @admin
          flash[:notice].should =~ /destroy yourself/i
          response.should redirect_to(user_path(@admin))
        end
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

  describe 'follow pages' do
    context 'when not signed in' do
      it 'protects following' do
        get :following, :id => 1
        response.should redirect_to(signin_path)
      end

      it 'protects followers' do
        get :followers, :id => 1
        response.should redirect_to(signin_path)
      end
    end

    context 'when signed-in' do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @other_user = Factory(:user, :email => Factory.next(:email))
        @user.follow!(@other_user)
      end

      it 'shows user following' do
        get :following, :id => @user
        response.should have_selector('a', :href => user_path(@other_user), :content => @other_user.name)
      end

      it 'shows user followers' do
        get :followers, :id => @other_user
        response.should have_selector('a', :href => user_path(@user), :content => @user.name)
      end
    end
  end
end
