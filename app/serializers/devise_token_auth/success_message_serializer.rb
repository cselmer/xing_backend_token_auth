module DeviseTokenAuth
  class SuccessMessageSerializer
    def initialize(message)
      @message = message
    end

    attr_reader :message

    def as_json(options)
      json_response = { status: 'success' }
      json_response[:message] = message if message
      json_response
    end
  end
end
