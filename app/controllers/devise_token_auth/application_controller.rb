module DeviseTokenAuth
  class ApplicationController < DeviseController
    include DeviseTokenAuth::Concerns::SetUserByToken
    respond_to :json

    def success_message(message = nil)
      json_response = { status: 'success' }
      json_response[:message] = message if message
      json_response
    end

    def error_messages(*args)
      {
        status: 'error',
        errors: args
      }
    end

    def resource_serializer(resource)
      {
        status: "success",
        data: resource.as_json(except: [:tokens, :created_at, :updated_at])
      }
    end

    def error_serializer(*args)
      resource = args[0]
      response = {
        status: "error",
        data: resource.as_json(except: [:tokens, :created_at, :updated_at])
      }
      if args.length > 1
        args.shift
        response[:errors] = args
      else
        response[:errors] = resource.errors.to_hash.merge(full_messages: resource.errors.full_messages)
      end
      response
    end
  end
end
