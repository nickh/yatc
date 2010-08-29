# == Schema Information
# Schema version: 20100827060738
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'digest'

class User < ActiveRecord::Base
  attr_accessor   :password
  attr_accessible :name, :email, :password, :password_confirmation

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name,     :presence     => true,
                       :length       => {:maximum => 50}
  validates :email,    :presence     => true,
                       :format       => {:with => email_regex},
                       :uniqueness   => {:case_sensitive => false}
  validates :password, :presence     => true,
                       :confirmation => true,
                       :length       => {:within => 6..40}

  before_save :encrypt_password

  def self.authenticate(email, submitted_password)
    if user = find_by_email(email)
      return user if user.password_matches?(submitted_password)
    end
  end

  # Return true if the user's password matches the submitted password
  def password_matches?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  private

    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end
