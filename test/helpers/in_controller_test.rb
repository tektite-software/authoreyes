require 'test_helper'

describe Authoreyes::Helpers::InController do
  admin_user = FactoryGirl.build(:user, role: FactoryGirl.build(:admin_role))
  normal_user = FactoryGirl.build(:user, role: FactoryGirl.build(:role))

  describe 'functionality added to ActionController::Base' do

    it 'should add .permitted_to?' do
      ActionController::Base.instance_methods.must_include :permitted_to?
    end

    it 'should add .permitted_to!' do
      ActionController::Base.instance_methods.must_include :permitted_to?
    end
  end

  describe 'permitted_to?' do
    it 'returns false for when not allowed' do
      ActionController::Base.new.permitted_to?(
        :manage,
        :test_models,
        user: normal_user
      ).must_equal false
    end

    it 'returns true when allowed' do
      ActionController::Base.new.permitted_to?(
        :manage,
        :test_models,
        user: admin_user
      ).must_equal true
    end
  end

  describe 'Rails Controller integration', :capybara do
    test_model_normal = FactoryGirl.build(:test_model, user: normal_user)
    describe 'when a controller is authorized by default Authoreyes behavior' do
      it 'allows guests to visit pages allowed to them' do
        visit root_path
        page.status_code.must_equal 200
        # TODO: bug in line below.  Waiting for fix
        # page.must_have_content 'Test Models'
        page.has_text?('Test Models').must_equal true
      end

      it 'stops guests from creating things' do
        visit new_test_model_path
        page.current_path.must_equal root_path
        page.status_code.must_equal 403
        # page.must_have_selector '.flash', text: 'You are not allowed to do that.'
      end
    end
  end
end
