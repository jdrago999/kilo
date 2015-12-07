
class Consumer < ActiveRecord::Base
  belongs_to :channel
  belongs_to :user
  validates_presence_of :channel_id, :user_id
  validates_uniqueness_of :user_id, scope: :channel_id
  has_many :channel_messages, foreign_key: :channel_id
  has_many :messages, through: :channel_messages
end
