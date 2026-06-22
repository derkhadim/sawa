class RenameAgentRoleToAgence < ActiveRecord::Migration[7.2]
  def up
    User.where(role: 'agent').update_all(role: 'agence')
  end

  def down
    User.where(role: 'agence').update_all(role: 'agent')
  end
end
