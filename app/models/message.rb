
class Message < ActiveRecord::Base
  validates_presence_of :data
end
