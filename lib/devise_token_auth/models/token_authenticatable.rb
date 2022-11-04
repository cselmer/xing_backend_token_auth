module Devise
  module Models
    module TokenAuthenticatable
      extend ActiveSupport::Concern

      included do
        serialize :tokens, JSON
        # can't set default on text fields in mysql, simulate here instead.
        after_save :set_empty_token_hash
        after_initialize :set_empty_token_hash
        before_save :destroy_expired_tokens

        # override devise method to include additional info as opts hash
        def send_confirmation_instructions(opts = nil)
          generate_confirmation_token! unless @raw_confirmation_token

          opts ||= {}

          # fall back to "default" config name
          opts[:client_config] ||= 'default'

          opts[:to] = unconfirmed_email if pending_reconfirmation?

          send_devise_notification(:confirmation_instructions, @raw_confirmation_token, opts)
        end

        # override devise method to include additional info as opts hash
        def send_reset_password_instructions(opts = nil)
          token = set_reset_password_token

          opts ||= {}

          # fall back to "default" config name
          opts[:client_config] ||= 'default'

          opts[:to] = if pending_reconfirmation?
                        unconfirmed_email
                      else
                        email
                      end

          send_devise_notification(:reset_password_instructions, token, opts)

          token
        end
      end

      # this must be done from the controller so that additional params
      # can be passed on from the client
      def send_confirmation_notification?
        false
      end

      def valid_token?(token, client_id = 'default')
        # byebug
        client_id ||= 'default'

        return false unless tokens[client_id]

        token_is_current?(token, client_id) &&
          token_can_be_reused?(token, client_id)
      end

      def token_is_current?(token, client_id)
        # ensure that expiry and token are set
        tokens[client_id]['expiry'] &&
          tokens[client_id]['token'] &&

          # ensure that the token was created within the last two weeks
          DateTime.strptime(tokens[client_id]['expiry'].to_s, '%s') > Time.zone.now &&

          # ensure that the token is valid
          BCrypt::Password.new(tokens[client_id]['token']) == token
      end

      # allow batch requests to use the previous token
      def token_can_be_reused?(token, client_id)
        # ensure that the last token and its creation time exist
        tokens[client_id]['updated_at'].present? &&
          tokens[client_id]['last_token'].present? &&

          # ensure that previous token falls within the batch buffer throttle time of the last request
          Time.parse(tokens[client_id]['updated_at']) > Time.zone.now - DeviseTokenAuth.batch_request_buffer_throttle &&

          # ensure that the token is valid
          BCrypt::Password.new(tokens[client_id]['last_token']) == token
      end

      # update user's auth token (should happen on each request)
      def create_new_auth_token(client_id = nil)
        client_id ||= SecureRandom.urlsafe_base64(nil, false)
        last_token = nil
        token        = SecureRandom.urlsafe_base64(nil, false)
        token_hash   = BCrypt::Password.create(token)
        expiry       = (Time.zone.now + DeviseTokenAuth.token_lifespan).to_i

        last_token = tokens[client_id]['token'] if tokens[client_id] && tokens[client_id]['token']

        tokens[client_id] = {
          'token' => token_hash,
          'expiry' =>  expiry,
          'last_token' => last_token,
          'updated_at' => Time.zone.now
        }

        save!

        build_auth_header(token, client_id)
      end

      def build_auth_header(token, client_id = 'default')
        client_id ||= 'default'

        # client may use expiry to prevent validation request if expired
        # must be cast as string or headers will break
        expiry = tokens[client_id]['expiry'].to_s

        {
          'access-token' => token,
          'token-type' => 'Bearer',
          'client' => client_id,
          'expiry' => expiry,
          'uid' => uid
        }
      end

      def build_auth_url(base_url, args)
        args[:uid]    = uid
        args[:expiry] = tokens[args[:client_id]]['expiry']

        generate_url(base_url, args)
      end

      def extend_batch_buffer(token, client_id)
        tokens[client_id]['updated_at'] = Time.zone.now
        save!

        build_auth_header(token, client_id)
      end

      protected

      # ensure that fragment comes AFTER querystring for proper $location
      # parsing using AngularJS.
      def generate_url(url, params = {})
        uri = URI(url)

        res = "#{uri.scheme}://#{uri.host}"
        res += ":#{uri.port}" if uri.port and uri.port != 80 and uri.port != 443
        res += "#{uri.path}#" if uri.path
        res += uri.fragment.to_s if uri.fragment
        res += "?#{params.to_query}"

        res
      end

      def set_empty_token_hash
        self.tokens ||= {} if has_attribute?(:tokens)
      end

      def destroy_expired_tokens
        self.tokens.delete_if do |_cid, v|
          expiry = v['expiry'].presence || v['expiry']
          next(false) unless expiry

          Time.at(expiry) < Time.zone.now
        end
        # byebug
        true
      end
    end
  end
end
