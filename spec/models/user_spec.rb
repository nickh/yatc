require 'spec_helper'

describe User do
  before(:each) do
    @user_attrs = {
      :name                  => 'Example User',
      :email                 => 'user@example.com',
      :password              => 'foobar',
      :password_confirmation => 'foobar',
    }
  end

  it 'creates a new instance given valid attributes' do
    User.create!(@user_attrs)
  end

  context 'name validation' do
    it 'requires a name' do
      user = User.new(@user_attrs.merge(:name => ''))
      user.should_not be_valid
      user.errors_on(:name).should_not be_empty
    end

    it 'rejects names that are too long' do
      long_name = 'a' * 51
      user = User.new(@user_attrs.merge(:name => long_name))
      user.should_not be_valid
      user.errors_on(:name).should_not be_empty
    end
  end

  context 'password validation' do
    it 'requires a password' do
      user = User.new(@user_attrs.merge(:password => '', :password_confirmation => ''))
      user.should_not be_valid
      user.errors_on(:password).should_not be_empty
    end

    it 'requires a matching password confirmation' do
      user = User.new(@user_attrs.merge(:password_confirmation => 'invalid'))
      user.should_not be_valid
      user.errors_on(:password).should_not be_empty
    end

    it 'rejects short passwords' do
      short_password = 'a' * 5
      user = User.new(@user_attrs.merge(:password => short_password, :password_confirmation => short_password))
      user.should_not be_valid
      user.errors_on(:password).should_not be_empty
    end

    it 'rejects long passwords' do
      long_password = 'a' * 41
      user = User.new(@user_attrs.merge(:password => long_password, :password_confirmation => long_password))
      user.should_not be_valid
      user.errors_on(:password).should_not be_empty
    end
  end

  context 'password encryption' do
    before(:each) do
      @user = User.create!(@user_attrs)
    end

    it 'has an encrypted password' do
      @user.should respond_to(:encrypted_password)
    end

    it 'sets the encrypted password' do
      @user.encrypted_password.should_not be_blank
    end

    describe '#password_matches?' do
      it 'returns true if the password matches' do
        @user.password_matches?(@user_attrs[:password]).should be_true
      end

      it 'returns false if the password does not match' do
        @user.password_matches?('invalid').should be_false
      end
    end

    describe '#authenticate' do
      it 'returns nil if the email address is not found' do
        user = User.authenticate('bar@foo.com', @user_attrs[:password])
        user.should be_nil
      end

      it 'returns nil if on email/password mismatch' do
        user = User.authenticate(@user_attrs[:email], 'wrongpass')
        user.should be_nil
      end

      it 'returns the user if the email and password match' do
        user = User.authenticate(@user_attrs[:email], @user_attrs[:password])
        user.should == @user
      end
    end
  end

  context 'email address validation' do
    it 'requires an email address' do
      user = User.new(@user_attrs.merge(:email => ''))
      user.should_not be_valid
      user.errors_on(:email).should_not be_empty
    end

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
end
