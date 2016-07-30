class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
end

class Minitest::Spec
  include FactoryGirl::Syntax::Methods
end

class Minitest::Unit::TestCase
  include FactoryGirl::Syntax::Methods
end

FactoryGirl.find_definitions
