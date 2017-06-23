class CreateGrandTestModels < ActiveRecord::Migration[5.0]
  def change
    create_table :grand_test_models do |t|
      t.string :title

      t.timestamps
    end
  end
end
