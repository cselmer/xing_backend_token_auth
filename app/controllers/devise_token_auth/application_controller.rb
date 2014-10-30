module DeviseTokenAuth
  class ApplicationController < DeviseController
    include DeviseTokenAuth::Concerns::SetUserByToken
    respond_to :json

    def success_message(message = nil)
      serializer = DeviseTokenAuth.success_message_serializer || SuccessMessageSerializer
      serializer.new(message)
    end

    def error_messages(*args)
      serializer = DeviseTokenAuth.error_messages_serializer || ErrorMessagesSerializer
      serializer.new(*args)
    end

    def error_serializer(*args)
      serializer = DeviseTokenAuth.error_serializer || ResourceErrorsSerializer
      serializer.new(*args)
    end

  end
end
