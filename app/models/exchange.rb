
class Exchange < ActiveRecord::Base
  belongs_to :vhost
  validates_presence_of :vhost_id, :name
  validates_uniqueness_of :name, scope: :vhost_id
  validates :fanout, inclusion: { in: [true, false] }

  has_many :bonds
  has_many :channels, through: :bonds
end
