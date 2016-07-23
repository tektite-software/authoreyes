class User < ApplicationRecord
  belongs_to :role
  has_many :test_models
  
  def role_symbols
    [role.title.to_sym]
  end
end
