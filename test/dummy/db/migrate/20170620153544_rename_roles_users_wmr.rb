class RenameRolesUsersWmr < ActiveRecord::Migration[5.0]
  def change
    rename_table :roles_user_with_multiples_roles, :roles_user_with_multiple_roles
  end
end
