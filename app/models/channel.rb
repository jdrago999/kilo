
class Channel < ActiveRecord::Base
  belongs_to :vhost
  validates_presence_of :vhost_id, :name
  validates_uniqueness_of :name, scope: :vhost_id

  has_many :consumers

  def publish(message)
  end

  def broadcast(message)
  end
end
