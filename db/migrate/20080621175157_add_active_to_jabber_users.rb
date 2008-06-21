class AddActiveToJabberUsers < ActiveRecord::Migration
  def self.up
    add_column :jabber_users, :active, :boolean, :default => false
  end

  def self.down
    remove_column :jabber_users, :active
  end
end
