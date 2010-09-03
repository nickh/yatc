require 'spec_helper'

describe MicropostsController do
  render_views

  describe 'access control' do
    context 'for a not-signed-in user' do
      it 'denies access to #create' do
        post :create
        response.should redirect_to(signin_path)
      end

      it 'denies access to #destroy' do
        delete :destroy, :id => 1
        response.should redirect_to(signin_path)
      end
    end
  end

  describe 'POST #create' do
    before(:each) do
      @user = test_sign_in(Factory(:user))
    end

    describe 'failure' do
      before(:each) do
        @micropost_attrs = {:content => ''}
      end

      it 'does not create a micropost' do
        lambda do
          post :create, :micropost => @micropost_attrs
        end.should_not change(Micropost, :count)
      end

      it 'renders the home page' do
        post :create, :micropost => @micropost_attrs
        response.should render_template('pages/home')
      end
    end

    describe 'success' do
      before(:each) do
        @micropost_attrs = {:content => 'Lorem ipsum'}
      end

      it 'creates a micropost' do
        lambda do
          post :create, :micropost => @micropost_attrs
        end.should change(Micropost, :count).by(1)
      end

      it 'redirects to the home page' do
        post :create, :micropost => @micropost_attrs
        response.should redirect_to(root_path)
      end

      it 'has a flash message' do
        post :create, :micropost => @micropost_attrs
        flash[:success].should =~ /micropost created/i
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'for an unauthorized user' do
      before(:each) do
        micropost_user = Factory(:user)
        @micropost = Factory(:micropost, :user => micropost_user)
        other_user = Factory(:user, :email => Factory.next(:email))
        test_sign_in(other_user)
      end

      it 'denies access' do
        delete :destroy, :id => @micropost
        response.should redirect_to(root_path)
      end

      it 'does not destroy the micropost' do
        lambda{delete :destroy, :id => @micropost}.should_not change(Micropost, :count)
      end
    end

    context 'for an authorized user' do
      before(:each) do
        micropost_user = test_sign_in(Factory(:user))
        @micropost = Factory(:micropost, :user => micropost_user)
      end

      it 'destroys the micropost' do
        lambda{delete :destroy, :id => @micropost}.should change(Micropost, :count).by(-1)
      end
    end
  end
end
