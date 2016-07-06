# Authoreyes::Parser
require 'authoreyes/parser/priveleges_reader'
require 'authoreyes/parser/authorization_rules_parser'
require 'authoreyes/parser/dsl_parser'
require 'authoreyes/authorization'

module Authoreyes
  # Parses an authorization configuration file in the authorization DSL and
  # constructs a data model of its contents.
  module Parser
    # Signals that the specified file to load was not found.
    class DSLFileNotFoundError < Exception; end
    # Signals errors that occur while reading and parsing an authorization DSL
    class DSLError < Exception; end
    # Signals errors in the syntax of an authorization DSL.
    class DSLSyntaxError < DSLError; end
  end
end
