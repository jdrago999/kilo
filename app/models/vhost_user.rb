
class VhostUser < ActiveRecord::Base
  belongs_to :vhost
  belongs_to :user
  validates_presence_of :vhost_id, :user_id
  validates_uniqueness_of :user_id, scope: :vhost_id
end
