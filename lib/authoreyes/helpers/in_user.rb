require 'authoreyes/helpers/in_user/instance_methods'

module Authoreyes
  module Helpers
    # This module contains helpers for the Authoreyes User object;
    # the object which received privileges.
    module InUser
      extend ActiveSupport::Concern

      module ClassMethods
        # Includes all helpers from the InUser::InstanceMethods module
        def is_authoreyes_user
          include Authoreyes::Helpers::InUser::InstanceMethods
        end
      end

      class RoleInterpolationError < StandardError
        def message
          'Could not automatically generate role_symbols for User.  Please define this method in your User model returning an array of symbols the user has, even if there is only one role.'
        end
      end
    end
  end
end
