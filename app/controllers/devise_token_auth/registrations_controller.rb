module DeviseTokenAuth
  class RegistrationsController < DeviseTokenAuth::ApplicationController

    before_filter :set_user_by_token, :only => [:destroy, :update]
    skip_after_filter :update_auth_header, :only => [:create, :destroy]

    respond_to :json

    def create
      build_resource(sign_up_params)

      resource.uid        = sign_up_params[resource_class.authentication_keys.first]

      # success redirect url is required
      unless !defined?(resource.confirmed?) or params[:confirm_success_url]
        return render json: {
          status: 'error',
          data:   resource,
          errors: ["Missing `confirm_success_url` param."]
        }, status: 403
      end

      begin
         # override email confirmation, must be sent manually from ctrl
        User.skip_callback("create", :after, :send_on_create_confirmation_instructions)

	      if resource.save
          if defined?(resource.confirmed?) and !resource.confirmed?
            resource.send_confirmation_instructions({
              client_config: params[:config_name],
              redirect_url: params[:confirm_success_url]
            })
          else
            # email auth has been bypassed, authenticate user
            @user      = resource
            @client_id = SecureRandom.urlsafe_base64(nil, false)
            @token     = SecureRandom.urlsafe_base64(nil, false)

            @user.tokens[@client_id] = {
              token: BCrypt::Password.create(@token),
              expiry: (Time.zone.now + DeviseTokenAuth.token_lifespan).to_i
            }

            @user.save!

            update_auth_header
          end

          render json: resource_serializer(resource)
        else
          clean_up_passwords resource
          render json: error_serializer(resource), status: 403
        end
      rescue ActiveRecord::RecordNotUnique
        clean_up_passwords resource
        render json: error_serializer(resource, "An account already exists for #{resource.send(resource_class.authentication_keys.first)}"), status: 403
      end
    end

    def update
      if @user
        if @user.update_attributes(account_update_params)
          render json: resource_serializer(@user)
        else
          render json: error_serializer(@user), status: 403
        end
      else
        render json: error_messages("User not found."), status: 404
      end
    end

    def destroy
      if @user
        @user.destroy

        render json: success_message("Account with uid #{@user.uid} has been destroyed.")
      else
        render json: error_messages("Unable to locate account for destruction."), status: 404
      end
    end

    def build_resource(hash=nil)
      self.resource = resource_class.new_with_session(hash || {}, session)
    end

    def sign_up_params
      devise_parameter_sanitizer.sanitize(:sign_up)
    end

    def account_update_params
      devise_parameter_sanitizer.sanitize(:account_update)
    end

    def resource_serializer(user)
      serializer = DeviseTokenAuth.registration_serializer || ResourceSerializer
      serializer.new(user)
    end
  end
end
