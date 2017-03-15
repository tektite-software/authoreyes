require 'rails'
require 'authoreyes/version'
require 'authoreyes/parser'
require 'authoreyes/authorization'
require 'authoreyes/railtie'

module Authoreyes
  class Railtie
    # Require helpers after Rails initialization
    config.after_initialize do
      require 'authoreyes/helpers/in_controller'

      # Include Controller helpers not already sent to specific parts
      # of ActionController (e.g., permitted_to?, etc.)
      ActionController::Metal.include Authoreyes::Helpers::InController
    end
  end
end
