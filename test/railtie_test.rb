require 'test_helper'

describe Authoreyes::Railtie do
  it 'sets up configuration for Authoreyes' do
    Rails.application.config.authoreyes.wont_be_nil
    Rails.application.config.authoreyes
         .must_be_instance_of ActiveSupport::OrderedOptions
  end

  it 'should set up Authoreyes::ENGINE as a constant auth engine instance' do
    Authoreyes::ENGINE.wont_be_nil
    Authoreyes::ENGINE.must_be_instance_of Authoreyes::Authorization::Engine
  end
end
