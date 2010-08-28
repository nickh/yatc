require 'spec_helper'

describe User do
  before(:each) do
    @user_attrs = {:name => 'Example User', :email => 'user@example.com'}
  end

  it 'creates a new instance given valid attributes' do
    User.create!(@user_attrs)
  end

  it 'requires a name' do
    user = User.new(@user_attrs.merge(:name => ''))
    user.should_not be_valid
    user.errors_on(:name).should_not be_empty
  end

  it 'requires an email address' do
    user = User.new(@user_attrs.merge(:email => ''))
    user.should_not be_valid
    user.errors_on(:email).should_not be_empty
  end

  it 'rejects names that are too long' do
    long_name = 'a' * 51
    user = User.new(@user_attrs.merge(:name => long_name))
    user.should_not be_valid
    user.errors_on(:name).should_not be_empty
  end

  context 'with duplicate email addresses' do
    it 'rejects duplicates with the same case' do
      User.create!(@user_attrs)
      user = User.new(@user_attrs)
      user.should_not be_valid
      user.errors_on(:email).should_not be_empty
    end

    it 'rejects duplicates with different case' do
      upcased_email = @user_attrs[:email].upcase
      User.create!(@user_attrs)
      user = User.new(@user_attrs.merge(:email => upcased_email))
      user.should_not be_valid
      user.errors_on(:email).should_not be_empty
    end
  end

  context 'with valid email address formats' do
    %w{user@foo.com THE_USER@foo.bar.org first.last@foo.co.jp}.each do |valid_address|
      it "accepts #{valid_address}" do
        user = User.new(@user_attrs.merge(:email => valid_address))
        user.should be_valid
      end
    end
  end

  context 'with invalid email address formats' do
    %w{user@foo,com user_at_foo.org example.user@foo}.each do |invalid_address|
      it "rejects #{invalid_address}" do
        user = User.new(@user_attrs.merge(:email => invalid_address))
        user.should_not be_valid
        user.errors_on(:email).should_not be_empty
      end
    end
  end
end
