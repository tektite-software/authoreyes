class Role < ApplicationRecord
  has_many :users
  has_and_belongs_to_many :users_with_multiples_roles

  def self.admin
    find_by(title: 'admin')
  end

  def self.user
    find_by(title: 'user')
  end
end
