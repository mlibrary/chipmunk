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

ActiveRecord::Schema.define(version: 20190301184824) do

  create_table "audits", force: :cascade do |t|
    t.integer "user_id"
    t.integer "packages"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_audits_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.integer "package_id"
    t.string "event_type"
    t.integer "user_id"
    t.string "outcome"
    t.string "detail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "audit_id"
    t.index ["audit_id"], name: "index_events_on_audit_id"
    t.index ["package_id"], name: "index_events_on_package_id"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "packages", force: :cascade do |t|
    t.string "bag_id", null: false
    t.integer "user_id", null: false
    t.string "external_id", null: false
    t.string "storage_location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "content_type", default: "default", null: false
    t.index ["bag_id"], name: "index_packages_on_bag_id", unique: true
    t.index ["external_id"], name: "index_packages_on_external_id", unique: true
    t.index ["user_id"], name: "index_packages_on_user_id"
  end

  create_table "queue_items", force: :cascade do |t|
    t.integer "package_id"
    t.integer "status", default: 0, null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["package_id"], name: "index_queue_items_on_package_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_key_digest", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
