
class Message < ActiveRecord::Base
  validates_presence_of :data
  has_many :exchange_messages
  has_many :exchanges, through: :exchange_messages
end
