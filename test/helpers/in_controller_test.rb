require 'test_helper'

describe Authoreyes::Helpers::InController do
  admin_user = User.first
  normal_user = User.find 2

  describe 'functionality added to ActionController::Base' do

    it 'should add .permitted_to?' do
      ActionController::Base.must_respond_to :permitted_to?
    end

    it 'should add .permitted_to!' do
      ActionController::Base.must_respond_to :permitted_to!
    end
  end

  describe 'permitted_to?' do
    it 'returns false for when not allowed' do
      ActionController::Base.permitted_to?(:manage, :test_models, user: normal_user).must_equal false
    end
  end
end
