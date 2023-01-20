class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :configure_permitted_parameters, if: :devise_controller?

  respond_to :json

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:operating_thetan, :favorite_color])
    devise_parameter_sanitizer.permit(:account_update, keys: [:operating_thetan, :favorite_color])
  end
end
