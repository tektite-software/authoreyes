class GrandTestModel < ApplicationRecord
  has_many :great_test_model
  belongs_to :user
end
