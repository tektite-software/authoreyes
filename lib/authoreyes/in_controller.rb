module Authoreyes
  # This module handles authorization at the Controller level.  It allows
  # various actions within the controller to be configured to work with
  # Authoreyes, only permitting access to that action if certain
  # conditions are met, according to the defined Authorization Rules.
  module InController

    def filter_resource_access(options = {})

    end

    # If the current user meets the given privilege, permitted_to? returns true
    # and yields to the optional block.  The attribute checks that are defined
    # in the authorization rules are only evaluated if an object is given
    # for context.
    #
    # See examples for Authorization::AuthorizationHelper #permitted_to?
    #
    # If no object or context is specified, the controller_name is used as
    # context.
    # TODO: Use permit? instead of permit!
    def permitted_to?(privelege, object_or_symbol = nil, options = {})
      if engine.permit!(
        privelege, options_for_permit(object_or_symbol, options, false)
      )
        yield if block_given?
        true
      else
        false
      end
    end

    # Works similar to the permitted_to? method, but
    # throws the authorization exceptions, just like Engine#permit!
    def permitted_to!(privelege, object_or_symbol = nil, options = {})
      engine.permit!(
        privelege, options_for_permit(object_or_symbol, options, true)
      )
    end
  end
end
