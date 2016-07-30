FactoryGirl.define do
  factory :test_model do
    title Faker::GameOfThrones.character
    body Faker::Lorem.paragraphs
    user
  end
end
