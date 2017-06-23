class CreateGreatTestModels < ActiveRecord::Migration[5.0]
  def change
    create_table :great_test_models do |t|
      t.string :title
      t.integer :grand_test_model_id

      t.timestamps
    end
  end
end
