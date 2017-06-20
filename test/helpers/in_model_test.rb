require 'test_helper'

describe Authoreyes::Helpers::InModel do
  admin_user = FactoryGirl.build(:user, role: FactoryGirl.build(:admin_role))
  normal_user = FactoryGirl.build(:user, role: FactoryGirl.build(:role))
  test_model = FactoryGirl.build(:test_model)
  test_model_for_user = FactoryGirl.build(:test_model, user: normal_user)

  describe 'include_privileges_for instance method' do
    it 'should be an available instance method without having to do anything' do
      test_model.must_respond_to :include_privileges_for
    end

    it 'should return the same object' do
      test_model.include_privileges_for.must_be_kind_of TestModel
      test_model.include_privileges_for.must_be_same_as test_model
    end

    it 'should get guest privileges with a nil argument' do
      test_model.include_privileges_for.attributes["privileges_for_user"].must_equal({index: true, show: true, read: true, create: false, new: false, edit: false, update: false, delete: false, destroy: false, manage: false})
    end

    it 'should get user privileges when a user is passed in' do
      test_model.include_privileges_for(normal_user).attributes["privileges_for_user"].must_equal({index: true, show: true, read: true, create: false, new: false, edit: false, update: false, delete: false, destroy: false, manage: false})
    end
  end
end
