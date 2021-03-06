class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :user_subs, dependent: :destroy
  has_many :subscriptions
  has_many :subscriptions, through: :user_subs
  has_many :events, through: :subscriptions
  has_many :alerts
  has_many :topics
  #not ready yet
  #has_many :comments
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, omniauth_providers: [:facebook]

  #->Prelang (user_login/devise)
  #has_many :subscriptions
  #has_many :user_subs
  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(provider: auth.provider, uid: auth.uid).first

    # The User was found in our database
    return user if user

    # Check if the User is already registered without Facebook
    user = User.where(email: auth.info.email).first

    return user if user

    # The User was not found and we need to create them
    User.create(name:     auth.extra.raw_info.name,
                provider: auth.provider,
                uid:      auth.uid,
                email:    auth.info.email,
                password: Devise.friendly_token[0,20])
  end


  attr_accessor :login
  
  #->Prelang (user_login:devise/username_login_support)
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", {value: login.downcase}]).first
    else
      where(conditions).first
    end
  end

  #ch12 listing 12.10
  #subscribes to a subscription
  def subscribe(example_subscription)
    user_subs.create(subscription_id: example_subscription.id)
  end

  #unsubscribes a user
  def unsubscribe(example_subscription)
    user_subs.find_by(subscription_id: example_subscription.id).destroy
  end

  #returns true if the current user is subscribed to a sub
  def subscribed?(example_subscription)
    if user_subs.find_by(subscription_id: example_subscription.id)
      return true
    else
      return false
    end
  end

  devise authentication_keys: [:login]
end
