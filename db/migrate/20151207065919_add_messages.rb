class AddMessages < ActiveRecord::Migration
  def change
    create_table :consumers do |t|
      t.references :channel
      t.references :user
      t.timestamps null: false
    end

    add_index :consumers, [:channel_id, :user_id], unique: true
    add_foreign_key :consumers, :channels,
                    dependent: :delete

    create_table :messages do |t|
      t.text :data
      t.timestamps null: false
    end

    create_table :exchange_messages do |t|
      t.references :exchange
      t.references :message
    end
    add_index :exchange_messages, [:exchange_id, :message_id], unique: true
    add_foreign_key :exchange_messages, :exchanges,
                    dependent: :delete
    add_foreign_key :exchange_messages, :messages,
                    dependent: :delete
  end
end
