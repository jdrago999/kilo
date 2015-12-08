
class ExchangeMessage < ActiveRecord::Base
  belongs_to :exchange
  belongs_to :message
  validates_presence_of :exchange_id, :message_id
  validates_uniqueness_of :message_id, scope: :exchange_id
end
