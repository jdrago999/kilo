
class ChannelController < ApplicationController
  include ActionController::Live
  before_filter :authenticate!
  before_filter :require_valid_vhost!
  before_filter :require_valid_channel!, only: [
    :delete,
    :subscribe,
    :publish,
    :broadcast,
    :ack
  ]
  before_filter :require_vhost_write!, only: [
    :create,
    :publish,
    :broadcast
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
      consumer = current_vhost_user.consumers.create!(channel: current_channel)
      while true do
        consumer_messages = consumer.consume(params[:prefetch] || 1)
        sse.write({messages: consumer_messages.map(&:message).map(&:data)}, {event: 'refresh'})
        sleep 1
      end
    rescue IOError
      # Render text just to keep rspec happy, so we don't get missing template errors.
      render text: ''
    ensure
      sse.close
      consumer.delete
    end
  end

  def publish
    raise ActionController::BadRequest.new unless params[:messages].is_a? Array

    messages = Channel.transaction do
      params[:messages].map do |message_data|
        current_channel.publish( message_data )
      end
    end

    render json: {
      success: true,
      published: messages.count
    }
  end

  def broadcast
    raise ActionController::BadRequest.new unless params[:messages].is_a? Array

    messages = Channel.transaction do
      params[:messages].map do |message_data|
        current_channel.broadcast( message_data )
      end
    end

    render json: {
      success: true,
      published: messages.count
    }
  end

  def ack
    raise ActionController::BadRequest.new unless params[:consumer_messages].is_a? Array

    consumer = current_vhost_user.consumers.where(channel_id: current_channel.id).first
    result = Message.transaction do
      consumer_messages = consumer.consumer_messages.where(id: params[:consumer_messages])
      message_ids = consumer_messages.map(&:message_id)
      consumer_messages.destroy_all
      Message.where(id: message_ids).destroy_all
    end
    render json: {
      success: true,
      acked: result
    }
  end

end
