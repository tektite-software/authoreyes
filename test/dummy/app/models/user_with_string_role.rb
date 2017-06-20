class UserWithStringRole < ApplicationRecord
  is_authoreyes_user
  def role
    'user'
  end
end
