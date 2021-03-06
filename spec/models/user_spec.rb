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

  describe 'admin attribute' do
    before(:each) do
      @user = User.create!(@user_attrs)
    end

    it 'responds to admin' do
      @user.should respond_to(:admin)
    end

    it 'is not admin by default' do
      @user.should_not be_admin
    end

    it 'can be set on' do
      @user.toggle!(:admin)
      @user.should be_admin
    end
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

  describe 'micropost associations' do
    before(:each) do
      @user = User.create(@user_attrs)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end

    it 'has a microposts attribute' do
      @user.should respond_to(:microposts)
    end

    it 'orders microposts correctly' do
      @user.microposts.should == [@mp2, @mp1]
    end

    it 'destroys associated microposts' do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end

    describe 'status feed' do
      it 'has a feed' do
        @user.should respond_to(:feed)
      end

      it "includes the user's microposts" do
        @user.feed.should include(@mp1)
        @user.feed.should include(@mp2)
      end

      it "does not include a different user's microposts" do
        mp3 = Factory(:micropost, :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.should_not include(mp3)
      end

      it 'includes the microposts of followed users' do
        followed = Factory(:user, :email => Factory.next(:email))
        mp3 = Factory(:micropost, :user => followed)
        @user.follow!(followed)
        @user.feed.should include(mp3)
      end
    end
  end

  describe 'relationships association' do
    before(:each) do
      @user = User.create!(@user_attrs)
      @followed = Factory(:user)
    end

    it 'exists' do
      @user.should respond_to(:relationships)
    end

    it 'provides reverse relationships' do
      @user.should respond_to(:reverse_relationships)
    end

    it 'has a following' do
      @user.should respond_to(:following)
    end

    it 'has followers' do
      @user.should respond_to(:followers)
    end

    it 'knows if a user is following another' do
      @user.should respond_to(:following?)
    end

    it 'allows a user to follow another' do
      @user.should respond_to(:follow!)
    end

    it 'allows a user to unfollow another' do
      @user.should respond_to(:unfollow!)
    end

    it 'creates a relationship when a user follows another user' do
      @user.follow!(@followed)
      @user.should be_following(@followed)
    end

    it 'destroys a relationship when a user unfollows another user' do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end

    it 'returns a list of following users' do
      @user.follow!(@followed)
      @user.following.should include(@followed)
    end

    it 'returns a list of followers' do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
    end
  end
end
