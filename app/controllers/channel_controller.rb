
class ChannelController < ApplicationController
  include ActionController::Live
  before_filter :authenticate!
  before_filter :require_valid_vhost!
  before_filter :require_valid_channel!, only: [
    :bind,
    :delete,
    :bonds,
    :get_bond,
    :unbind,
    :subscribe,
    :publish
  ]
  before_filter :require_vhost_write!, only: [
    :create,
    :bind,
    :unbind,
    :publish
  ]
  before_filter :require_vhost_read!, only: [
    :list,
    :bonds,
    :get_bond,
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

  def bind
    exchange = current_vhost.exchanges.find_by(name: params[:exchange])
    unless exchange
      return render json: {
        success: false,
        errors: ["invalid exchange '#{params[:exchange]}'"]
      }, status: 400
    end

    bond = current_channel.bonds.first_or_create(exchange: exchange)
    if bond.valid?
      return render json: {
        success: true,
        path: show_bond_path(vhost: current_channel.vhost.name, channel: current_channel.name, bond_id: bond.id)
      }, status: 201
    else
      return render json: {
        success: false,
        errors: bond.errors.map{|name, msg| "#{name} #{msg}" }
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

  def bonds
    render json: {
      success: true,
      items: current_channel.bonds.map do |bond|
        {
          id: bond.id
        }
      end
    }
  end

  def get_bond
    if bond = current_channel.bonds.find_by(id: params[:bond_id])
      render json: {
        id: bond.id
      }
    else
      return not_found
    end
  end

  def unbind
    if bond = current_channel.bonds.find_by(id: params[:bond_id])
      bond.delete
      render json: {
        success: true
      }
    else
      return not_found
    end
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

  def publish
    message = Message.create!(data: params[:message])


    render json: {
      success: true,
      path: 'foo'
    }
  end

end
