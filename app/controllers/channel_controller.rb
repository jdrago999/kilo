
class ChannelController < ApplicationController
  include ActionController::Live
  before_filter :authenticate!
  before_filter :require_valid_vhost!
  before_filter :require_valid_channel!, only: [
    :bind,
    :delete,
    :subscribe,
    :publish
  ]
  before_filter :require_vhost_write!, only: [
    :create,
    :publish
  ]
  before_filter :require_vhost_read!, only: [
    :list,
    :subscribe
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

  def list
    render json: {
      success: true,
      items: current_vhost.channels.map do |channel|
        {
          name: channel.name
        }
      end
    }
  end

  def delete
    current_channel.delete
    render json: {
      success: true
    }
  end

  def subscribe
    response.headers['Content-Type'] = 'text/event-stream'
    sse = Kilo::SSE.new(response.stream)
    begin
      while true do
        messages = []
        sse.write({messages: messages}, {event: 'refresh'})
        sleep 1
      end
    rescue IOError
      # Render text just to keep rspec happy, so we don't get missing template errors.
      render text: ''
    ensure
      sse.close
    end
  end

end
