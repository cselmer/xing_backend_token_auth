module DeviseTokenAuth
  class ResourceErrorsSerializer
    def initialize(*args)
      @args = args
    end

    attr_reader :args

    def as_json(options)
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
