class UserWithMultipleRole < ApplicationRecord
  is_authoreyes_user
  has_and_belongs_to_many :roles
end
