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

      # Include Controller helpers
      ActionController::Base.extend Authoreyes::Helpers::InController
    end
  end
end
