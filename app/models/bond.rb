
class Bond < ActiveRecord::Base
  belongs_to :exchange
  belongs_to :channel
  validates_presence_of :exchange_id, :channel_id
  validates_uniqueness_of :channel_id, scope: :exchange_id
end
