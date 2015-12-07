# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151207065919) do

  create_table "bonds", force: :cascade do |t|
    t.integer  "exchange_id", limit: 4
    t.integer  "channel_id",  limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "bonds", ["channel_id"], name: "fk_rails_e4f102f80c", using: :btree
  add_index "bonds", ["exchange_id", "channel_id"], name: "index_bonds_on_exchange_id_and_channel_id", unique: true, using: :btree

  create_table "channel_messages", force: :cascade do |t|
    t.integer "channel_id", limit: 4
    t.integer "message_id", limit: 4
  end

  add_index "channel_messages", ["channel_id", "message_id"], name: "index_channel_messages_on_channel_id_and_message_id", unique: true, using: :btree
  add_index "channel_messages", ["message_id"], name: "fk_rails_b746f9a29c", using: :btree

  create_table "channels", force: :cascade do |t|
    t.integer  "vhost_id",   limit: 4
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "channels", ["vhost_id", "name"], name: "index_channels_on_vhost_id_and_name", unique: true, using: :btree

  create_table "consumers", force: :cascade do |t|
    t.integer  "channel_id", limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "consumers", ["channel_id", "user_id"], name: "index_consumers_on_channel_id_and_user_id", unique: true, using: :btree

  create_table "exchanges", force: :cascade do |t|
    t.integer  "vhost_id",   limit: 4
    t.string   "name",       limit: 255
    t.boolean  "fanout",     limit: 1,   default: false, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "exchanges", ["vhost_id", "name"], name: "index_exchanges_on_vhost_id_and_name", unique: true, using: :btree

  create_table "messages", force: :cascade do |t|
    t.text     "data",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",        limit: 255,                 null: false
    t.string   "password_digest", limit: 255
    t.boolean  "is_admin",        limit: 1,   default: false, null: false
    t.string   "uid",             limit: 255
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "users", ["uid"], name: "index_users_on_uid", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "vhost_users", force: :cascade do |t|
    t.integer  "vhost_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.boolean  "conf",       limit: 1, default: false, null: false
    t.boolean  "write",      limit: 1, default: false, null: false
    t.boolean  "read",       limit: 1, default: false, null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "vhost_users", ["user_id"], name: "fk_rails_53ebf7361e", using: :btree
  add_index "vhost_users", ["vhost_id", "user_id"], name: "index_vhost_users_on_vhost_id_and_user_id", unique: true, using: :btree

  create_table "vhosts", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "vhosts", ["name"], name: "index_vhosts_on_name", unique: true, using: :btree

  add_foreign_key "bonds", "channels"
  add_foreign_key "bonds", "exchanges"
  add_foreign_key "channel_messages", "channels"
  add_foreign_key "channel_messages", "messages"
  add_foreign_key "channels", "vhosts"
  add_foreign_key "consumers", "channels"
  add_foreign_key "exchanges", "vhosts"
  add_foreign_key "vhost_users", "users"
  add_foreign_key "vhost_users", "vhosts"
end
