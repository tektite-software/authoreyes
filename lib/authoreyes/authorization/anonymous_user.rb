module Authoreyes
  module Authorization
    # Represents a pseudo-user to facilitate anonymous users in applications
    class AnonymousUser
      attr_reader :role_symbols
      def initialize(roles = [Authorization.default_role])
        @role_symbols = roles
      end
    end
  end
end
