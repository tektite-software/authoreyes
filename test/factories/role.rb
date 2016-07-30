FactoryGirl.define do
  factory :role do
    title 'user'
  end

  factory :admin_role, parent: :role do
    title 'admin'
  end
end
