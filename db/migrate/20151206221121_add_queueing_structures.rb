class AddQueueingStructures < ActiveRecord::Migration
  def change

    create_table :channels do |t|
      t.references :vhost
      t.string :name
      t.timestamps null: false
    end

    add_index :channels, [:vhost_id, :name], unique: true
    add_foreign_key :channels, :vhosts,
                    dependent: :delete
  end
end
