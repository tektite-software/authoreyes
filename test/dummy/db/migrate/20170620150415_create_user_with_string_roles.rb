class CreateUserWithStringRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :user_with_string_roles do |t|

      t.timestamps
    end
  end
end
