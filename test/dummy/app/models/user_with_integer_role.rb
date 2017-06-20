class UserWithIntegerRole < ApplicationRecord
  is_authoreyes_user

  def role
    1234
  end
end
