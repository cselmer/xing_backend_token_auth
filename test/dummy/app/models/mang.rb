class Mang < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable,
        :confirmable, :token_authenticatable

  include DeviseTokenAuth::Concerns::User
end
