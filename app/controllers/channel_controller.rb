
class ChannelController < ApplicationController
  before_filter :authenticate!
  before_filter :require_valid_vhost!
  before_filter :require_vhost_write!, only: [
    :create
  ]

  def create
    channel = current_vhost.channels.first_or_create( name: params[:name] )
    if channel.valid?
      return render json: {
        success: true,
        path: show_channel_path(vhost: channel.vhost.name, channel: channel.name)
      }, status: 201
    else
      return render json: {
        success: false,
        errors: channel.errors.map{|name, msg| "#{name} #{msg}" }
      }, status: 400
    end
  end
end
