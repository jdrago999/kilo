
class Consumer < ActiveRecord::Base
  belongs_to :channel
  belongs_to :vhost_user
  validates_presence_of :channel_id, :vhost_user_id
  validates_uniqueness_of :vhost_user_id, scope: :channel_id
  has_many :consumer_messages
  has_many :messages, through: :consumer_messages
end
