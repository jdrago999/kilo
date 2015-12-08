
class Channel < ActiveRecord::Base
  belongs_to :vhost
  validates_presence_of :vhost_id, :name
  validates_uniqueness_of :name, scope: :vhost_id

  has_many :consumers
  has_many :messages
  has_many :consumer_messages, through: :consumers

  def publish(message_data)
    self.messages.create(data: message_data)
  end

  def broadcast(message_data)
    transaction do
      consumer_ids = self.consumers.pluck(:id)
      return nil if consumer_ids.empty?
      message = self.messages.create!(data: message_data)
      data = consumer_ids.map do |consumer_id|
        {
          consumer_id: consumer_id,
          message_id: message.id
        }
      end.to_a
      consumer_messages = ConsumerMessage.create(data)
      message
    end
  end
end
