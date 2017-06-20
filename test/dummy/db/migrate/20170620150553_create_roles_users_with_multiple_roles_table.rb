class CreateRolesUsersWithMultipleRolesTable < ActiveRecord::Migration[5.0]
  def change
    create_table(:roles_users_with_multiple_roles_tables, id: false) do |t|
      t.integer :role_id, null: false
      t.integer :user_with_multiple_role_id, null: false
    end
  end
end
