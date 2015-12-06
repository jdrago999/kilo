
class AuthController < ApplicationController
  def auth
    if user = User.find_by(username: params[:username])
      if user.authenticate( params[:password] )
        auth_token = self.sign_in(user)
        render json: {
          success: true,
          uid: user.uid,
          auth_token: auth_token
        }
      else
        raise AuthorizationException.new
      end
    else
      raise AuthorizationException.new
    end
  end
end
