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

ActiveRecord::Schema.define(version: 20140217212046) do

  create_table "contacts", force: true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.string   "phone"
    t.string   "display_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.datetime "invitation_sent_at"
    t.integer  "corresponding_user_id"
  end

  create_table "messages", force: true do |t|
    t.integer  "user_id"
    t.text     "body"
    t.string   "audio_file_name"
    t.boolean  "delivered_to_all"
    t.float    "lat"
    t.float    "lon"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "audio_content_type"
  end

  create_table "preferences", force: true do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipients", force: true do |t|
    t.integer  "message_id"
    t.integer  "user_id"
    t.datetime "delivered_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "retrieved_at"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "encrypted_password"
    t.integer  "sign_in_count"
    t.datetime "current_sign_in_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_name"
    t.string   "access_token"
    t.string   "salt"
    t.string   "mobile"
    t.string   "home"
    t.string   "office"
    t.string   "homepage"
    t.string   "status"
  end

end
