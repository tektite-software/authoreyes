class CreateUserWithIntegerRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :user_with_integer_roles do |t|

      t.timestamps
    end
  end
end
