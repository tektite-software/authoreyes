class AddUserIdToGrandTestModels < ActiveRecord::Migration[5.0]
  def change
    add_column :grand_test_models, :user_id, :integer
  end
end
