require 'test_helper'

describe Authoreyes do
  it 'should have a version' do
    ::Authoreyes::VERSION.wont_be_nil
  end

  it 'should require Rails' do
    Rails::VERSION.wont_be_nil
  end

  it 'should have some test users set up' do
    User.count.must_be :>=, 2
  end

  it 'should have some test roles set up' do
    Role.count.must_be :>=, 2
  end

  the 'test users should return role symbols' do
    User.first.role_symbols.must_be_instance_of Array
  end

  the 'role sybols are formatted properly' do
    User.first.role_symbols.must_equal [:admin]
  end

  it 'should set up some test models' do
    TestModel.count.must_be :>=, 2
  end

  it 'should have at least one test model for admin' do
    TestModel.find_by(user_id: 1).wont_be_nil
  end

  it 'should have atl east one test model for normal user' do
    TestModel.find_by(user_id: 2).wont_be_nil
  end
end
