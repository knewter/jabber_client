class CreateJabberUsers < ActiveRecord::Migration
  def self.up
    create_table :jabber_users do |t|
      t.string :login
      t.string :password
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :jabber_users
  end
end
