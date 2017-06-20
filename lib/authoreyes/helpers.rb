require 'authoreyes/helpers/in_controller'
require 'authoreyes/helpers/in_user'
require 'authoreyes/helpers/in_model'

module Authoreyes
  # This module contains all helpers for views, controllers, and models.
  module Helpers
    # +Authoreyes::Helpers::guest_privileges_on+
    # Returns a hash of booleans for each guest privelege on the
    # object or context passed in.
    # Use this to check the privileges a guest or unauthenticated user
    # would have on a particular object.
    # Also see +privileges_on+ in Authoreyes::Helpers::InUser
    #
    # ==== Examples
    #
    #   # Example Authorization Rules
    #   authorization do
    #     role :guest do
    #       has_permission_on :example_objects, to: [:index, :show]
    #     end
    #   end
    #
    #   Authoreyes::Helpers::guest_privileges_on(@example_object)
    #   # => { index: true, show: true, create: false, update: false, delete: false }
    def self.guest_privileges_on(object_or_context)
      result = {}
      engine = Authoreyes::ENGINE
      privileges = engine.privileges
      privileges.each do |e|
        if object_or_context.is_a?(Symbol)
          result.merge! e => engine.permit?(e, context: object_or_context, user: nil)
        else
          result.merge! e => engine.permit?(e, object: object_or_context, user: nil)
        end
      end
      result
    end
  end
end
