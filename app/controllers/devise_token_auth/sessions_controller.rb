# see http://www.emilsoman.com/blog/2013/05/18/building-a-tested/
module DeviseTokenAuth
  class SessionsController < DeviseTokenAuth::ApplicationController
    before_filter :set_user_by_token, :only => [:destroy]
    prepend_before_filter :allow_params_authentication!, only: :create
    prepend_before_filter only: [ :create, :destroy ] { request.env["devise.skip_timeout"] = true }

    def create
      self.resource = warden.authenticate!(auth_options)
      sign_in(resource_name, resource, :store => false)
      @user = resource
      @client_id = SecureRandom.urlsafe_base64(nil, false)
      @token     = SecureRandom.urlsafe_base64(nil, false)

      @user.tokens[@client_id] = {
        token: BCrypt::Password.create(@token),
        expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
      }
      @user.save
      yield resource if block_given?
      render json: resource_serializer(resource)
    end

    def auth_options
      { scope: resource_name, recall: "#{controller_path}#new" }
    end

    def destroy
      # remove auth instance variables so that after_filter does not run
      user = remove_instance_variable(:@user) if @user
      client_id = remove_instance_variable(:@client_id) if @client_id
      remove_instance_variable(:@token) if @token

      if user and client_id and user.tokens[client_id]
        user.tokens.delete(client_id)
        user.save!

        render json: success_message, status: 200

      else
        render json: error_messages("User was not found or was not logged in."), status: 404
      end
    end

  end
end
