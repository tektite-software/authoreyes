class RenameRolesUsersWithMultipleRolesToRolesUserWithMultiplesRoles < ActiveRecord::Migration[5.0]
  def change
    rename_table :roles_users_with_multiple_roles_tables, :roles_user_with_multiples_roles
  end
end
