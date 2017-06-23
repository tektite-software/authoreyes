class AddGreatTestModelIdToGrandTestModels < ActiveRecord::Migration[5.0]
  def change
    add_column :grand_test_models, :great_test_model_id, :integer
  end
end
