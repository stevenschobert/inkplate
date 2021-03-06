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

ActiveRecord::Schema.define(version: 20160322002449) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.integer "parent_id"
    t.string  "name"
    t.string  "description"
  end

  create_table "categorized_posts", force: :cascade do |t|
    t.integer "category_id"
    t.integer "post_id"
  end

  add_index "categorized_posts", ["category_id"], name: "index_categorized_posts_on_category_id", using: :btree
  add_index "categorized_posts", ["post_id"], name: "index_categorized_posts_on_post_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.integer  "status",        default: 0
    t.integer  "kind",          default: 0
    t.string   "title"
    t.string   "slug"
    t.text     "excerpt"
    t.text     "more_text"
    t.text     "body"
    t.json     "custom_fields"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "posts", ["kind"], name: "index_posts_on_kind", using: :btree
  add_index "posts", ["status"], name: "index_posts_on_status", using: :btree

  create_table "uploads", force: :cascade do |t|
    t.string  "name"
    t.string  "mime_type"
    t.integer "size"
    t.string  "dropbox_url"
    t.string  "dropbox_id"
    t.string  "dropbox_path"
    t.string  "dropbox_rev"
  end

  add_index "uploads", ["dropbox_id"], name: "index_uploads_on_dropbox_id", unique: true, using: :btree
  add_index "uploads", ["dropbox_url"], name: "index_uploads_on_dropbox_url", using: :btree

end
