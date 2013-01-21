class User < ActiveRecord::Base
  has_many :authentications
  before_save :check_password_nil

  acts_as_authentic do |c|
    c.merge_validates_confirmation_of_password_field_options({:unless => :networked?})
    c.merge_validates_length_of_password_field_options({:unless => :networked?})
    c.merge_validates_length_of_password_confirmation_field_options({:unless => :networked?})
  end
  acts_as_permissible

  def check_password_nil
    if self.networked? and self.crypted_password.nil?
      self.crypted_password = ''
      self.password_salt = ''
    end
  end

  def networked?
    self.authentications.any?
  end

  def apply_omniauth(omniauth)
    puts "OMNIAUTH apply_omniauth:\n" 
    pp omniauth.inspect 
    puts "\n************"

    self.email = omniauth['info']['email'] if self.email.to_s.empty?
    if not omniauth['info']['name'].to_s.empty? 
      self.name = omniauth['info']['name'] if self.name.to_s.empty? 
    end

    # Update user info fetching from social network
    case omniauth['provider']
    when 'facebook'
      # fetch extra user info from facebook
    when 'twitter'
      # fetch extra user info from twitter
    end
  end
end