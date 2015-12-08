
class Consumer < ActiveRecord::Base
  belongs_to :channel
  belongs_to :vhost_user
  validates_presence_of :channel_id, :vhost_user_id
  validates_uniqueness_of :vhost_user_id, scope: :channel_id
  has_many :consumer_messages
  has_many :messages, through: :consumer_messages

  def consume(count=1)
    transaction do
      message_ids = channel.unclaimed_messages.limit(count).pluck(:id)
      self.consumer_messages.create( message_ids.map{|id| {message_id: id} }.to_a )
    end
  end
end
