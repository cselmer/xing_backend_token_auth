require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class RegistrationsControllerRoutingTest < ActionController::TestCase
  describe RegistrationsController do

    test "should route to post" do
      assert_routing({method: 'post', path: '/auth'}, {controller: "registrations", action: "create"})
    end
  end
end
