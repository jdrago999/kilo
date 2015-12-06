class Authentication < ActiveRecord::Migration
  def change
    create_table :vhosts do |t|
      t.string :name, null: false
      t.timestamps null: false
    end

    add_index :vhosts, :name, unique: true

    create_table :users do |t|
      t.string :username, null: false
      t.string :password_digest
      t.boolean :is_admin, null: false, default: false
      t.string :uid
      t.timestamps null: false
    end

    add_index :users, :username, unique: true
    add_index :users, :uid, unique: true

    create_table :vhost_users do |t|
      t.references :vhost
      t.references :user
      t.boolean :conf, null: false, default: false
      t.boolean :write, null: false, default: false
      t.boolean :read, null: false, default: false
      t.timestamps null: false
    end

    add_index :vhost_users, [:vhost_id, :user_id], unique: true
    add_foreign_key :vhost_users, :vhosts,
                    dependent: :delete
    add_foreign_key :vhost_users, :users,
                    dependent: :delete
  end
end
