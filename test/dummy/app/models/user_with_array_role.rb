class UserWithArrayRole < ApplicationRecord
  is_authoreyes_user

  def roles
    ['Guest', User, :admin]
  end
end
