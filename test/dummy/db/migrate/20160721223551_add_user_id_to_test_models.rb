class AddUserIdToTestModels < ActiveRecord::Migration[5.0]
  def change
    add_column :test_models, :user_id, :integer
  end
end
