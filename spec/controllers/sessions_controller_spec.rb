require 'spec_helper'

describe SessionsController do
  render_views

  describe "GET 'new'" do
    it "succeeds" do
      get 'new'
      response.should be_success
    end

    it 'has the right title' do
      get :new
      response.should have_selector('title', :content => 'Sign In')
    end
  end

  describe "POST 'create'" do
    context 'with invalid credentials' do
      before(:each) do
        @session_attrs = {:email => 'email@example.com', :password => 'invalid'}
      end

      it 're-renders the new page' do
        post :create, :session => @session_attrs
        response.should render_template('new')
      end

      it 'has the right title' do
        post :create, :session => @session_attrs
        response.should have_selector('title', :content => 'Sign In')
      end
    end

    context 'with valid credentials' do
      before(:each) do
        @user = Factory(:user)
        @session_attrs = {:email => @user.email, :password => @user.password}
      end

      it 'signs the user in' do
        post :create, :session => @session_attrs
        controller.current_user.should == @user
        controller.should be_signed_in
      end

      it 'redirects to the user show page' do
        post :create, :session => @session_attrs
        response.should redirect_to(user_path(@user))
      end
    end
  end

  describe "DELETE 'destroy'" do
    it 'signs the user out' do
      test_sign_in(Factory(:user))
      delete :destroy
      controller.should_not be_signed_in
      response.should redirect_to(root_path)
    end
  end
end
