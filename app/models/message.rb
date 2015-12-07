
class Message < ActiveRecord::Base
  validates_presence_of :data
  has_many :channel_messages
  has_many :channels, through: :channel_messages
end
