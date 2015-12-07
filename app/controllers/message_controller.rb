
class MessageController < ApplicationController
  before_filter :authenticate!
  before_filter :require_valid_vhost!
  before_filter :require_valid_channel!, only: [
    :bind,
    :delete,
    :bonds,
    :get_bond,
    :unbind
  ]
  before_filter :require_vhost_write!, only: [
    :create,
    :bind,
    :unbind
  ]

  def create
    render json: {
      success: true,
      path: 'foo'
    }
  end

end
