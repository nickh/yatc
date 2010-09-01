require 'spec_helper'

describe "Users" do
  describe 'signup' do
    describe 'failure' do
      it 'does not make a new user' do
        lambda do
          visit signup_path
          fill_in "Name",                  :with => ''
          fill_in "Email",                 :with => ''
          fill_in "Password",              :with => ''
          fill_in "Password confirmation", :with => ''
          click_button
          response.should render_template('users/new')
          response.should have_selector('div#error_explanation')
        end.should_not change(User, :count)
      end
    end

    describe 'success' do
      it 'makes a new user' do
        lambda do
          visit signup_path
          fill_in "Name",                  :with => 'Example User'
          fill_in "Email",                 :with => 'user@example.com'
          fill_in "Password",              :with => 'foobar'
          fill_in "Password confirmation", :with => 'foobar'
          click_button
          response.should render_template('users/show')
        end.should change(User, :count).by(1)
      end
    end
  end

  describe 'sign in/out' do
    describe 'failure' do
      it 'does not sign a user in' do
        user = User.new(:name => '', :password => '')
        integration_sign_in user
        response.should have_selector('div.flash.error', :content => 'Invalid')
      end
    end

    describe 'success' do
      it 'signs a user in and out' do
        user = Factory(:user)
        integration_sign_in user
        controller.should be_signed_in
        click_link 'Sign out'
        controller.should_not be_signed_in
      end
    end
  end

  describe 'user list' do
    context 'as a non-admin user' do
      before(:each) do
        integration_sign_in Factory(:user)
        click_link 'Users'
      end

      it 'does not have delete links' do
        response.should_not have_selector('a', :content => 'delete')
      end
    end

    context 'as an admin user' do
      before(:each) do
        @admin_user = Factory(:user, :admin => true)
        @other_user = Factory(:user, :email => 'other_user@example.com')
        integration_sign_in @admin_user
        click_link 'Users'
      end

      it 'has delete links for other accounts' do
        response.should have_selector('a', :content => 'delete', :href => user_path(@other_user))
      end

      it 'does not have a delete link for their own account' do
        response.should_not have_selector('a', :content => 'delete', :href => user_path(@admin_user))
      end
    end
  end
end
