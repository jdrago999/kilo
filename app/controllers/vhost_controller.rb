
class VhostController < ApplicationController

  before_filter :authenticate!
  before_filter :require_admin_user!

  def create
    vhost = Vhost.first_or_create( name: params[:name] )
    if vhost.valid?
      return render json: {
        success: true,
      }, status: 201
    else
      return render json: {
        success: false,
        errors: vhost.errors.map{|name, msg| "#{name} #{msg}" }
      }, status: 400
    end
  end

  def delete
    vhost = Vhost.find_by(name: params[:name]) or return not_found
    vhost.delete
    render json: {
      success: true
    }
  end

end
