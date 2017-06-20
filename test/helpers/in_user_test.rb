require 'test_helper'

describe Authoreyes::Helpers::InUser do
  admin_user = FactoryGirl.build(:user, role: FactoryGirl.build(:admin_role))
  normal_user = FactoryGirl.build(:user, role: FactoryGirl.build(:role))
  test_model = FactoryGirl.build(:test_model)
  test_model_for_user = FactoryGirl.build(:test_model, user: normal_user)

  it 'adds is_authoreyes_user to ActiveRecord::Base' do
    ActiveRecord::Base.must_respond_to :is_authoreyes_user
  end

  it 'does not add instance methods to non-User models' do
    test_model.wont_respond_to :role_symbols
    test_model.wont_respond_to :privileges_on
  end

  it 'provides role_symbols for users with multiple roles' do
    user_with_multiple_roles = UserWithMultipleRole.create(roles: [Role.user, Role.admin])

    user_with_multiple_roles.must_respond_to :role_symbols
    user_with_multiple_roles.role_symbols.must_be_kind_of Array
    user_with_multiple_roles.role_symbols.must_equal [:user, :admin]

    user_with_multiple_roles.destroy
  end

  it 'provides role_symbols for users with a single role' do
    normal_user.must_respond_to :role_symbols
    normal_user.role_symbols.must_be_kind_of Array
    normal_user.role_symbols.must_equal [:user]
  end

  it 'provides role_symbols for users with a string role' do
    user_with_string_role = UserWithStringRole.create

    user_with_string_role.must_respond_to :role_symbols
    user_with_string_role.role_symbols.must_be_kind_of Array
    user_with_string_role.role_symbols.must_equal [:user]

    user_with_string_role.destroy
  end

  it 'attempts to provides role_symbols for users with a custom array of roles' do
    user_with_array_roles = UserWithArrayRole.create

    user_with_array_roles.must_respond_to :role_symbols
    user_with_array_roles.role_symbols.must_be_kind_of Array
    user_with_array_roles.role_symbols.must_equal [:guest, :user, :admin]

    user_with_array_roles.destroy
  end

  it 'raises an error if the role_symbols could not be interpolated' do
    user_with_integer_role = UserWithIntegerRole.create

    proc { user_with_integer_role.role_symbols }.must_raise Authoreyes::Helpers::InUser::RoleInterpolationError

    user_with_integer_role.destroy
  end

  it 'provides privileges_on helper to User' do
    normal_user.must_respond_to :privileges_on
    normal_user.privileges_on(test_model).must_be_kind_of Hash
    normal_user.privileges_on(test_model).must_equal({index: true, show: true, read: true, create: false, new: false, edit: false, update: false, delete: false, destroy: false, manage: false})
    normal_user.privileges_on(test_model_for_user).must_equal({index: true, show: true, read: true, create: true, new: true, edit: true, update: true, delete: true, destroy: true, manage: true})
  end

  it 'provides top-level guest_privileges_on helper' do
    Authoreyes::Helpers.must_respond_to :guest_privileges_on
    Authoreyes::Helpers.guest_privileges_on(test_model).must_be_kind_of Hash
    Authoreyes::Helpers.guest_privileges_on(test_model).must_equal({index: true, show: true, read: true, create: false, new: false, edit: false, update: false, delete: false, destroy: false, manage: false})
    Authoreyes::Helpers.guest_privileges_on(test_model_for_user).must_equal({index: true, show: true, read: true, create: false, new: false, edit: false, update: false, delete: false, destroy: false, manage: false})
  end
end
