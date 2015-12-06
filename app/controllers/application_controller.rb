
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
    return token
  end

  rescue_from AuthorizationException do
    render text: "Access Denied", status: :unauthorized
  end

  def current_user
    return unless @user_id
    @current_user ||= User.find_by(id: @user_id)
  end

  protected

  def authenticate!
    nonce = http_header :x_auth_nonce
    uid = http_header :x_auth_uid
    digest = http_header :x_auth_digest
    unless nonce && uid && digest
      raise ::AuthorizationException.new
    end

    token = self.redis.get("kilo.auth-token:#{uid}") or raise ::AuthorizationException.new
    calculated_digest = Digest::SHA2.new.hexdigest( [request.raw_post, nonce, token].join('') )

    if digest.downcase == calculated_digest.downcase
      @user = User.find_by(uid: uid)
      @user_id = @user.id
    else
      raise ::AuthorizationException.new
    end
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
