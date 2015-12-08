
class Channel < ActiveRecord::Base
  belongs_to :vhost
  validates_presence_of :vhost_id, :name
  validates_uniqueness_of :name, scope: :vhost_id

  has_many :consumers

  def publish(message_data)
    return unless consumer = self.consumers.order('RAND()').first
    message = consumer.messages.create(data: message_data)
    consumer.id
  end

  def broadcast(message_data)
  end
end
