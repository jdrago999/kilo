
class MessageController < ApplicationController
  before_filter :authenticate!
  before_filter :require_valid_vhost!
  before_filter :require_valid_channel!, only: [
  ]
  before_filter :require_vhost_write!, only: [
  ]


end
