require 'spec_helper'

describe RelationshipsController do
  describe 'access control' do
    it 'requires signin for create' do
      post :create
      response.should redirect_to(signin_path)
    end

    it 'requires signin for destroy' do
      post :destroy, :id => 1
      response.should redirect_to(signin_path)
    end
  end

  describe 'POST #create' do
    before(:each) do
      @user = test_sign_in(Factory(:user))
      @followed = Factory(:user, :email => Factory.next(:email))
    end

    it 'creates a relationship' do
      lambda do
        post :create, :relationship => {:followed_id => @followed}
        response.should be_redirect
      end.should change(Relationship, :count).by(1)
    end

    describe 'using Ajax' do
      it 'creates a relationship' do
        lambda do
          xhr :post, :create, :relationship => {:followed_id => @followed}
          response.should be_success
        end.should change(Relationship, :count).by(1)
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      @user = test_sign_in(Factory(:user))
      @followed = Factory(:user, :email => Factory.next(:email))
      @user.follow!(@followed)
      @relationship = @user.relationships.find_by_followed_id(@followed)
    end

    it 'destroys a relationship' do
      lambda do
        delete :destroy, :id => @relationship
        response.should be_redirect
      end.should change(Relationship, :count).by(-1)
    end

    describe 'using Ajax' do
      it 'destroys a relationship' do
        lambda do
          xhr :delete, :destroy, :id => @relationship
          response.should be_success
        end.should change(Relationship, :count).by(-1)
      end
    end
  end
end
