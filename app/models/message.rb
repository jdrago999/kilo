
class Message < ActiveRecord::Base
  belongs_to :channel
  validates_presence_of :data, :channel_id
  has_many :consumer_messages
  has_many :consumers, through: :consumer_messages
end
