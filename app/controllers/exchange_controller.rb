
class ExchangeController < ApplicationController

  before_filter :authenticate!
  before_filter :require_valid_vhost!
  before_filter :require_vhost_conf!, only: [
    :create
  ]
  before_filter :require_vhost_read!, only: [
    :list
  ]

  def create
    exchange = current_vhost.exchanges.create(name: params[:name])
    unless exchange.valid?
      return render json: {
        success: false,
        error: exchange.errors.map{|name, msg| "#{name} #{msg}" }
      }, status: 400
    else
      render json: {
        success: true,
        path: show_exchange_path(vhost: exchange.vhost.name, exchange: exchange.name)
      }, status: 201
    end
  end

  def list
    render json: {
      success: true,
      items: current_vhost.exchanges.map do |exchange|
        {
          name: exchange.name
        }
      end
    }
  end

end
