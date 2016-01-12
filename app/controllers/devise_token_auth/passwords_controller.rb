module DeviseTokenAuth
  class PasswordsController < DeviseTokenAuth::ApplicationController
    before_filter :set_user_by_token, :only => [:update]
    skip_after_filter :update_auth_header, :only => [:create, :edit]

    # this action is responsible for generating password reset tokens and
    # sending emails
    def create
      unless resource_params[:email].present?
        return render json: error_messages('You must provide an email address.'), status: 401
      end

      unless params[:redirect_url]
        return render json: error_messages('Missing redirect url.'), status: 401
      end

      @user = resource_class.where({
        email: resource_params[:email]
      }).first

      errors = nil

      if @user
        @user.send_reset_password_instructions({
          email: resource_params[:email],
          redirect_url: params[:redirect_url],
          client_config: params[:config_name]
        })

        if @user.errors.empty?
          render json: success_message(
            "An email has been sent to #{@user.email} containing instructions for resetting your password."
          )
        else
          errors = @user.errors
        end
      else
        errors = ["Unable to find user with email '#{resource_params[:email]}'."]
      end

      if errors
        render json: error_messages(*errors), status: 400
      end
    end


    # this is where users arrive after visiting the email confirmation link
    def edit
      @user = resource_class.reset_password_by_token({
        reset_password_token: params[:reset_password_token]
      })

      if @user and @user.id
        client_id  = SecureRandom.urlsafe_base64(nil, false)
        token      = SecureRandom.urlsafe_base64(nil, false)
        token_hash = BCrypt::Password.create(token)
        expiry     = (Time.now + DeviseTokenAuth.token_lifespan).to_i

        @user.tokens[client_id] = {
          token:  token_hash,
          expiry: expiry
        }

        # ensure that user is confirmed
        @user.skip_confirmation! unless @user.confirmed_at

        @user.save!

        redirect_to(@user.build_auth_url(params[:redirect_url], {
          token:          token,
          client_id:      client_id,
          reset_password: true,
          config:         params[:config]
        }))
      else
        password_reset_rejection
      end
    end

    def password_reset_rejection
      raise ActionController::RoutingError.new('Not Found')
    end

    def update
      # make sure user is authorized
      unless @user
        return render json: error_messages('Unauthorized'), status: 401
      end

      # ensure that password params were sent
      unless password_resource_params[:password] and password_resource_params[:password_confirmation]
        return render json: error_messages('You must fill out the fields labeled "password" and "password confirmation".'), status: 422
      end

      if @user.update_attributes(password_resource_params)
        return render json: resource_serializer(@user)
      else
        return render json: error_serializer(@user), status: 422
      end
    end

    def password_resource_params
      devise_parameter_sanitizer.sanitize(:account_update)
    end

    def resource_serializer(user)
      serializer = DeviseTokenAuth.password_serializer || ResourceSerializer
      serializer.new(user)
    end
  end
end
