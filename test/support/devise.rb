class ActiveSupport::TestCase
  # include Devise::Test::ControllerHelpers
  include Warden::Test::Helpers
  Warden.test_mode!
end

class Minitest::Spec
  include ActiveSupport::Testing::SetupAndTeardown
  # include Devise::Test::ControllerHelpers
  include Warden::Test::Helpers
  Warden.test_mode!
end

# class Minitest::Unit::TestCase
#   include Devise::Test::ControllerHelpers
  include Warden::Test::Helpers
  Warden.test_mode!
# end
