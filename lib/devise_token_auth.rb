require "devise"
require "devise_token_auth/engine"
require "devise_token_auth/controllers/helpers"
require "devise_token_auth/controllers/url_helpers"

module DeviseTokenAuth
end

Devise.add_module :token_authenticatable, :model => 'devise_token_auth/models/token_authenticatable'
