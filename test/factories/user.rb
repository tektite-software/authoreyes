FactoryGirl.define do
  factory :user do
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    email { Faker::Internet.safe_email(first_name) }
    password Faker::Internet.password
    role
  end

  # factory :admin_user, parent: :user do
  #   role {}
  # end
end
