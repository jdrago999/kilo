
class AuthorizationException < StandardError
end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_filter :parse_json_params

  def sign_in(user)
    # Don't generate a new token if the old one is still valid:
    token = self.redis.get("kilo.auth-token:#{user.uid}") || user.generate_token
    self.redis.set("kilo.auth-token:#{user.uid}", token)
    @user_id = user.id.to_i
    @current_user = user
    session[:uid] = user.uid
    return session[:auth_token] = token
  end

  rescue_from AuthorizationException do
    render text: "Access Denied", status: :unauthorized
  end

  rescue_from ActionController::RoutingError do
    render text: "Not Found", status: :not_found
  end

  def current_user
    return unless @user_id
    @current_user ||= User.find_by(id: @user_id)
  end

  def current_vhost
    @current_vhost
  end

  def current_vhost_user
    @current_vhost_user
  end

  protected

  def authenticate!
    sent_token = session[:auth_token]
    token = self.redis.get("kilo.auth-token:#{session[:uid]}") or raise ::AuthorizationException.new

    if params.has_key? :vhost
      # Also check vhost:
      @current_vhost = Vhost.find_by(name: params[:vhost]) or raise ::ActionController::RoutingError.new 'not found'

      # Also check the vhost_user exists:
      @current_vhost_user = current_user.vhost_users.find_by(vhost_id: @current_vhost.id) or raise ::AuthorizationException.new
    end
  end

  def require_vhost_conf!
    current_vhost_user.conf or raise ::AuthorizationException.new
  end

  def require_vhost_read!
    current_vhost_user.read or raise ::AuthorizationException.new
  end

  def require_vhost_write!
    current_vhost_user.write or raise ::AuthorizationException.new
  end

  def require_valid_vhost!
    @current_vhost = Vhost.find_by(name: params[:vhost]) or return ::ActionController::RoutingError.new 'not found'
  end

  def parse_json_params
    if http_header(:content_type) == 'application/json'
      params.merge! JSON.parse(request.raw_post, symbolize_names: true)
    end
  end

  def http_header(name)
    http_header_name = name.to_s.underscore.upcase
    rack_header_name = name.to_s.titleize.split(/\s+/).join('-')
    extra_http_header_name = "HTTP_#{http_header_name}"
    request.env[http_header_name] || request.env[extra_http_header_name] || request.headers['rack.session'][rack_header_name] || request.headers['rack.session'][http_header_name]
  end

  def redis
    return @redis if @redis
    config = Rails.application.config.redis_connections[:auth_tokens]
    @redis = Redis.new(config)
  end
end
