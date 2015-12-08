
class ConsumerMessage < ActiveRecord::Base
  belongs_to :consumer
  belongs_to :message
  validates_presence_of :consumer_id, :message_id
  validates_uniqueness_of :message_id, scope: :consumer_id
end
