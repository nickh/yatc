require 'spec_helper'

describe Micropost do
  before(:each) do
    @user            = Factory(:user)
    @micropost_attrs = { :content => 'a sample micropost' }
  end

  it 'creates a new instance given valid attributes' do
    @user.microposts.create!(@micropost_attrs)
  end

  describe 'validations' do
    it 'requires a user id' do
      Micropost.new(@micropost_attrs).should_not be_valid
    end

    it 'requires nonblank content' do
      @user.microposts.build(:content => '  ').should_not be_valid
    end

    it 'rejects long content' do
      @user.microposts.build(:content => 'a' * 141).should_not be_valid
    end
  end

  describe 'user associations' do
    before(:each) do
      @micropost = @user.microposts.create(@micropost_attrs)
    end

    it 'has a user attribute' do
      @micropost.should respond_to(:user)
    end

    it 'has the right associated user' do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end
  end

  describe 'from_users_followed_by' do
    before(:each) do
      @user2 = Factory(:user, :email => Factory.next(:email))
      @user3 = Factory(:user, :email => Factory.next(:email))
      
      @user_post  = @user.microposts.create!(:content => 'foo')
      @user2_post = @user2.microposts.create!(:content => 'bar')
      @user3_post = @user3.microposts.create!(:content => 'baz')

      @user.follow!(@user2)
    end

    it 'responds' do
      Micropost.should respond_to(:from_users_followed_by)
    end

    it 'includes posts from the user' do
      Micropost.from_users_followed_by(@user).should include(@user_post)
    end

    it 'includes posts from followed users' do
      Micropost.from_users_followed_by(@user).should include(@user2_post)
    end

    it 'excludes posts from users not being followed' do
      Micropost.from_users_followed_by(@user).should_not include(@user3_post)
    end
  end
end
