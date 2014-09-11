require "devise"
require "devise_token_auth/engine"

module DeviseTokenAuth
end

Devise.add_module :token_authenticable, :model => 'devise_token_auth/models/token_authenticatable'