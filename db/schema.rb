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

ActiveRecord::Schema.define(version: 20151206020624) do

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

  add_index "vhost_users", ["user_id"], name: "fk_rails_56226146d3", using: :btree
  add_index "vhost_users", ["vhost_id", "user_id"], name: "index_vhost_users_on_vhost_id_and_user_id", unique: true, using: :btree

  create_table "vhosts", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "vhosts", ["name"], name: "index_vhosts_on_name", unique: true, using: :btree

  add_foreign_key "vhost_users", "users"
  add_foreign_key "vhost_users", "vhosts"
end
