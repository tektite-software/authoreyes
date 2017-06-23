FactoryGirl.define do
  sequence :email do |n|
    Faker::Internet.email("#{Faker::LordOfTheRings.character}#{n}")
  end

  factory :user do
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    email { generate :email }
    password Faker::Internet.password
    role
  end

  # factory :admin_user, parent: :user do
  #   role {}
  # end
end
