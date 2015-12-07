
class ChannelController < ApplicationController
  before_filter :authenticate!
  before_filter :require_valid_vhost!
  before_filter :require_valid_channel!, only: [
    :bind
  ]
  before_filter :require_vhost_write!, only: [
    :create,
    :bind
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
end
