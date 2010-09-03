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
end
