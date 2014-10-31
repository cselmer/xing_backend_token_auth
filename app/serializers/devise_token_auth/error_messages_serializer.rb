module DeviseTokenAuth
  class ErrorMessagesSerializer
    def initialize(*args)
      @args = args
    end

    attr_reader :args

    def as_json(options)
      {
        status: 'error',
        errors: args
      }
    end
  end
end
