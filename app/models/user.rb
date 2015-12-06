
class User < ActiveRecord::Base
  has_secure_password
  validates_presence_of :username
  validates_uniqueness_of :username
  has_many :vhost_users
  has_many :vhosts, through: :vhost_users

  before_validation :add_uid
  validates :uid, presence: true, uniqueness: true
  validates_each :uid do |record, attr, value|
    record.errors.add(attr, 'is not a valid UUID') unless UUID.validate(value)
  end

  def generate_token
    SecureRandom.uuid
  end

  private

  def add_uid
    self.uid = SecureRandom.uuid
  end
end
