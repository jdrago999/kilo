
class Message < ActiveRecord::Base
  validates_presence_of :data
  has_many :consumer_messages
  has_many :consumers, through: :consumer_messages
end
