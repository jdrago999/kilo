
class ChannelMessage < ActiveRecord::Base
  belongs_to :channel
  belongs_to :message
  validates_presence_of :channel_id, :message_id
  validates_uniqueness_of :message_id, scope: :channel_id
end
