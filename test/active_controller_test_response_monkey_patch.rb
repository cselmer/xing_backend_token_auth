if RUBY_VERSION >= '2.6.0'
  if Rails.version < '5'
    class ActionController::TestResponse < ActionDispatch::TestResponse
      def recycle!
        # HACK: to avoid MonitorMixin double-initialize error:
        if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.7.0')
          @mon_data = nil
          @mon_data_owner_object_id = nil
        else
          @mon_mutex = nil
          @mon_mutex_owner_object_id = nil
        end
        initialize
      end
    end
  else
    puts 'Monkeypatch for ActionController::TestResponse no longer needed'
  end

  class ActionController::LiveTestResponse < ActionController::Live::Response
    def recycle!
      @body = nil
      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.7.0')
        @mon_data = nil
        @mon_data_owner_object_id = nil
      else
        @mon_mutex = nil
        @mon_mutex_owner_object_id = nil
      end
      initialize
    end
  end
end
