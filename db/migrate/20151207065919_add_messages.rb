class AddMessages < ActiveRecord::Migration
  def change
    create_table :consumers do |t|
      t.references :channel
      t.references :vhost_user
      t.timestamps null: false
    end

    add_index :consumers, [:channel_id, :vhost_user_id], unique: true
    add_foreign_key :consumers, :channels,
                    dependent: :delete
    add_foreign_key :consumers, :vhost_users,
                    dependent: :delete

    create_table :messages do |t|
      t.text :data
      t.timestamps null: false
    end

    create_table :consumer_messages do |t|
      t.references :consumer
      t.references :message
      t.timestamps null: false
    end

    add_index :consumer_messages, [:consumer_id, :message_id], unique: true
    add_foreign_key :consumer_messages, :consumers,
                    dependent: :delete
    add_foreign_key :consumer_messages, :messages,
                    dependent: :delete
  end
end
