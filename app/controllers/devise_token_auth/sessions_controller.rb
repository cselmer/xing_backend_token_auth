# see http://www.emilsoman.com/blog/2013/05/18/building-a-tested/
module DeviseTokenAuth
  class SessionsController < Devise::SessionsController
    skip_before_filter :verify_signed_out_user, only: :destroy

    include Devise::Controllers::Helpers
    include DeviseTokenAuth::Concerns::SetUserByToken

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
      render json: {
        data: resource.as_json(except: [
            :tokens, :confirm_success_url, :reset_password_redirect_url, :created_at, :updated_at
        ])
      }
    end

    def destroy
      # remove auth instance variables so that after_filter does not run
      user = remove_instance_variable(:@user) if @user
      client_id = remove_instance_variable(:@client_id) if @client_id
      remove_instance_variable(:@token) if @token

      if user and client_id and user.tokens[client_id]
        user.tokens.delete(client_id)
        user.save!

        render json: {
          success:true
        }, status: 200

      else
        render json: {
          errors: ["User was not found or was not logged in."]
        }, status: 404
      end
    end

  end
end
