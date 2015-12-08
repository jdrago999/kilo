
class ExchangeController < ApplicationController

  before_filter :authenticate!
  before_filter :require_valid_vhost!
  before_filter :require_vhost_conf!, only: [
    :create
  ]
  before_filter :require_vhost_read!, only: [
    :list
  ]
  before_filter :require_vhost_write!, only: [
    :publish
  ]

  def create
    exchange = current_vhost.exchanges.create(name: params[:name])
    if exchange.valid?
      return render json: {
        success: true,
        path: show_exchange_path(vhost: exchange.vhost.name, exchange: exchange.name)
      }, status: 201
    else
      return render json: {
        success: false,
        errors: exchange.errors.map{|name, msg| "#{name} #{msg}" }
      }, status: 400
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

  def delete
    if exchange = current_vhost.exchanges.find_by(name: params[:exchange])
      exchange.delete
      render json: {
        success: true
      }
    else
      return not_found
    end
  end


  def publish
    exchange = current_vhost.exchanges.find_by(name: params[:exchange])
    message = exchange.messages.create(data: params[:message])

    render json: {
      success: true,
      path: 'foo'
    }
  end
end
