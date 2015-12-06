class AddQueueingStructures < ActiveRecord::Migration
  def change
    create_table :exchanges do |t|
      t.references :vhost
      t.string :name
      t.boolean :fanout, null: false, default: false
      t.timestamps null: false
    end

    add_index :exchanges, [:vhost_id, :name], unique: true
    add_foreign_key :exchanges, :vhosts,
                    dependent: :delete

    create_table :channels do |t|
      t.references :vhost
      t.string :name
      t.timestamps null: false
    end

    add_index :channels, [:vhost_id, :name], unique: true
    add_foreign_key :exchanges, :vhosts,
                    dependent: :delete

    create_table :bonds do |t|
      t.references :exchange
      t.references :channel
      t.timestamps null: false
    end

    add_index :bonds, [:exchange_id, :channel_id], unique: true
    add_foreign_key :bonds, :exchanges,
                    dependent: :delete
    add_foreign_key :bonds, :channels,
                    dependent: :delete
  end
end
