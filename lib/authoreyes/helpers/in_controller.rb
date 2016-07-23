module Authoreyes
  module Helpers
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
      # +privelege+ is the symbol name of the privele checked
      # +object_or_symbol+ is the object the privelege is checked on
      def permitted_to?(privelege, object_or_symbol = nil, options = {})
        if Authoreyes::ENGINE.permit!(
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
      # +privelege+ is the symbol name of the privele checked
      # +object_or_symbol+ is the object the privelege is checked on
      def permitted_to!(privelege, object_or_symbol = nil, options = {})
        Authoreyes::ENGINE.permit!(
          privelege, options_for_permit(object_or_symbol, options, true)
        )
      end

      # Create hash of options to be used with ENGINE's permit methods
      def options_for_permit (object_or_sym = nil, options = {}, bang = true)
        context = object = nil
        if object_or_sym.nil?
          context = self.class.decl_auth_context
        elsif !Authorization.is_a_association_proxy?(object_or_sym) and object_or_sym.is_a?(Symbol)
          context = object_or_sym
        else
          object = object_or_sym
        end

        result = {:object => object,
          :context => context,
          :skip_attribute_test => object.nil?,
          :bang => bang}.merge(options)
        result[:user] = current_user unless result.key?(:user)
        result
      end
    end
  end
end
