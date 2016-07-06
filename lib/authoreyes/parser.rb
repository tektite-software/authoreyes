# Authoreyes::Parser
require 'authoreyes/parser/priveleges_reader'
require 'authoreyes/parser/authorization_rules_parser'
require 'authoreyes/parser/dsl_parser'
require 'authoreyes/authorization'

module Authoreyes
  # Parses an authorization configuration file in the authorization DSL and
  # constructs a data model of its contents.
  #
  # For examples and the modeled data model, see the
  # README[link:files/README_rdoc.html].
  #
  # Also, see role definition methods
  # * AuthorizationRulesReader#role,
  # * AuthorizationRulesReader#includes,
  # * AuthorizationRulesReader#title,
  # * AuthorizationRulesReader#description
  #
  # Methods for rule definition in roles
  # * AuthorizationRulesReader#has_permission_on,
  # * AuthorizationRulesReader#to,
  # * AuthorizationRulesReader#if_attribute,
  # * AuthorizationRulesReader#if_permitted_to
  #
  # Methods to be used in if_attribute statements
  # * AuthorizationRulesReader#contains,
  # * AuthorizationRulesReader#does_not_contain,
  # * AuthorizationRulesReader#intersects_with,
  # * AuthorizationRulesReader#is,
  # * AuthorizationRulesReader#is_not,
  # * AuthorizationRulesReader#is_in,
  # * AuthorizationRulesReader#is_not_in,
  # * AuthorizationRulesReader#lt,
  # * AuthorizationRulesReader#lte,
  # * AuthorizationRulesReader#gt,
  # * AuthorizationRulesReader#gte
  #
  # And privilege definition methods
  # * PrivilegesReader#privilege,
  # * PrivilegesReader#includes
  #
  module Parser
    # Signals that the specified file to load was not found.
    class DSLFileNotFoundError < Exception; end
    # Signals errors that occur while reading and parsing an authorization DSL
    class DSLError < Exception; end
    # Signals errors in the syntax of an authorization DSL.
    class DSLSyntaxError < DSLError; end
  end
end
