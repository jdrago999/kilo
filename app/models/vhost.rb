
class Vhost < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :vhost_users
  has_many :exchanges
  has_many :users, through: :vhost_users
end
