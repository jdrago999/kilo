class AddMessages < ActiveRecord::Migration
  def change
    create_table :consumers do |t|
      t.references :channel
      t.references :vhost_user
      t.timestamps null: false
    end

    add_index :consumers, [:channel_id, :vhost_user_id], unique: true
    add_foreign_key :consumers, :channels,
                    name: :fk_consumers_to_channel,
                    dependent: :delete
    add_foreign_key :consumers, :vhost_users,
                    name: :fk_consumers_to_vhost_user,
                    dependent: :delete

    create_table :messages do |t|
      t.references :channel
      t.text :data
      t.timestamps null: false
    end
    add_index :messages, :created_at
    add_foreign_key :messages, :channels,
                    name: :fk_messages_to_channel,
                    dependent: :delete

    create_table :consumer_messages do |t|
      t.references :consumer
      t.references :message
      t.timestamps null: false
    end

    add_index :consumer_messages, [:consumer_id, :message_id], unique: true
    add_foreign_key :consumer_messages, :consumers,
                    name: :fk_consumer_messages_to_channel,
                    dependent: :delete
    add_foreign_key :consumer_messages, :messages,
                    name: :fk_consumer_messages_to_message,
                    dependent: :delete
  end
end
