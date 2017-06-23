FactoryGirl.define do
  factory :grand_test_model do
    title Faker::Pokemon.name
    user
  end
end
