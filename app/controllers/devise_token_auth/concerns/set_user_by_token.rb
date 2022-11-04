module DeviseTokenAuth::Concerns::SetUserByToken
  extend ActiveSupport::Concern
  include DeviseTokenAuth::Controllers::Helpers

  included do
    before_action :set_request_start
    after_action :update_auth_header
  end

  # keep track of request duration
  def set_request_start
    @request_started_at = Time.zone.now
  end

  # user auth
  def set_user_by_token(mapping=nil)

    # determine target authentication class
    self.mapping = mapping
    rc = resource_class

    # no default user defined
    return unless rc

    # user has already been found and authenticated
    return @user if @user and @user.class == rc

    # parse header for values necessary for authentication
    uid        = request.headers['uid']
    @token     = request.headers['access-token']
    @client_id = request.headers['client']

    return false unless @token

    # client_id isn't required, set to 'default' if absent
    @client_id ||= 'default'

    # mitigate timing attacks by finding by uid instead of auth token
    # byebug
    user = uid && rc.find_by_uid(uid)

    if user && user.valid_token?(@token, @client_id)
      sign_in(resource_name, user, store: false)
      @user = user
      return
    else
      # zero all values previously set values
      @user = nil
      return
    end
  end


  def update_auth_header

    # cannot save object if model has invalid params
    return unless @user and @user.valid? and @client_id

    # Lock the user record during any auth_header updates to ensure
    # we don't have write contention from multiple threads
    @user.with_lock do

      # determine batch request status after request processing, in case
      # another processes has updated it during that processing
      @is_batch_request = is_batch_request?(@user, @client_id)

      auth_header = {}

      if not DeviseTokenAuth.change_headers_on_each_request
        auth_header = @user.build_auth_header(@token, @client_id)

      # extend expiration of batch buffer to account for the duration of
      # this request
      elsif @is_batch_request
        auth_header = @user.extend_batch_buffer(@token, @client_id)

      # update Authorization response header with new token
      else
        auth_header = @user.create_new_auth_token(@client_id)
      end

      # update the response header
      response.headers.merge!(auth_header)

    end # end lock

  end

  def mapping
    @mapping ||= request.env['devise.mapping'] || Devise.mappings.values.first
  end

  def mapping=(m)
    @mapping = Devise.mappings[m]
  end

  def resource_class
    mapping.to
  end

  def resource_name
    mapping.name
  end

  private


  def is_batch_request?(user, client_id)
    user.tokens[client_id] and
    user.tokens[client_id]['updated_at'] and
    Time.parse(user.tokens[client_id]['updated_at']) > @request_started_at - DeviseTokenAuth.batch_request_buffer_throttle
  end
end
