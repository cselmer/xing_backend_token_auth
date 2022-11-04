module Overrides
  class SessionsController < DeviseTokenAuth::SessionsController
    OVERRIDE_PROOF = "(^^,)"

    def create
      self.resource = warden.authenticate!(auth_options)
      sign_in(resource_name, resource, :store => false)
      @client_id = SecureRandom.urlsafe_base64(nil, false)
      @token     = SecureRandom.urlsafe_base64(nil, false)
      @user = resource
      @user.tokens[@client_id] = {
          'token' =>  BCrypt::Password.create(@token),
          'expiry' => (Time.zone.now + DeviseTokenAuth.token_lifespan).to_i
      }
      @user.save

      yield resource if block_given?
      render json: {
        data: @user.as_json(except: [
          :tokens, :created_at, :updated_at
        ]),
        override_proof: OVERRIDE_PROOF
      }
    end
  end
end
