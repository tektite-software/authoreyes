class CreateNestedTestModels < ActiveRecord::Migration[5.0]
  def change
    create_table :nested_test_models do |t|
      t.integer :test_model_id
      t.string :title

      t.timestamps
    end
  end
end
