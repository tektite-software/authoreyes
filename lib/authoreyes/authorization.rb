# Authorization
require 'rails'
require 'authoreyes/authorization/engine'
require 'authoreyes/authorization/authorization_rule_set'
require 'authoreyes/authorization/authorization_rule'
require 'authoreyes/authorization/attribute'
require 'authoreyes/authorization/attribute_with_permission'
require 'authoreyes/authorization/anonymous_user'

require "set"
require "forwardable"

module Authorization
  # An exception raised if anything goes wrong in the Authorization realm
  class AuthorizationError < StandardError ; end
  # NotAuthorized is raised if the current user is not allowed to perform
  # the given operation possibly on a specific object.
  class NotAuthorized < AuthorizationError ; end
  # AttributeAuthorizationError is more specific than NotAuthorized, signaling
  # that the access was denied on the grounds of attribute conditions.
  class AttributeAuthorizationError < NotAuthorized ; end
  # AuthorizationUsageError is used whenever a situation is encountered
  # in which the application misused the plugin.  That is, if, e.g.,
  # authorization rules may not be evaluated.
  class AuthorizationUsageError < AuthorizationError ; end
  # NilAttributeValueError is raised by Attribute#validate? when it hits a nil attribute value.
  # The exception is raised to ensure that the entire rule is invalidated.
  class NilAttributeValueError < AuthorizationError ; end

  AUTH_DSL_FILES = [Pathname.new(Rails.root || '').join("config", "authorization_rules.rb").to_s] unless defined? AUTH_DSL_FILES

  # Controller-independent method for retrieving the current user.
  # Needed for model security where the current controller is not available.
  def self.current_user
    Thread.current["current_user"] || AnonymousUser.new
  end

  # Controller-independent method for setting the current user.
  def self.current_user=(user)
    Thread.current["current_user"] = user
  end

  # For use in test cases only
  def self.ignore_access_control (state = nil) # :nodoc:
    Thread.current["ignore_access_control"] = state unless state.nil?
    Thread.current["ignore_access_control"] || false
  end

  def self.activate_authorization_rules_browser? # :nodoc:
    ::Rails.env.development?
  end

  @@dot_path = "dot"
  def self.dot_path
    @@dot_path
  end

  def self.dot_path= (path)
    @@dot_path = path
  end

  @@default_role = :guest
  def self.default_role
    @@default_role
  end

  def self.default_role= (role)
    @@default_role = role.to_sym
  end

  def self.is_a_association_proxy? (object)
    if Rails.version < "3.2"
      object.respond_to?(:proxy_reflection)
    else
      object.respond_to?(:proxy_association)
    end
  end
end
