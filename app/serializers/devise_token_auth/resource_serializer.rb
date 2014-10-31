module DeviseTokenAuth

  class ResourceSerializer
    def initialize(resource)
      @resource = resource
    end
    attr_reader :resource

    def as_json(options)
      {
        status: "success",
        data: resource.as_json(except: [:tokens, :created_at, :updated_at])
      }
    end

  end
end
