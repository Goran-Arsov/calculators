# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_18_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "blog_posts", force: :cascade do |t|
    t.text "body", null: false
    t.string "category"
    t.datetime "created_at", null: false
    t.string "excerpt", null: false
    t.string "meta_description"
    t.string "meta_title"
    t.datetime "published_at"
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["published_at"], name: "index_blog_posts_on_published_at"
    t.index ["slug"], name: "index_blog_posts_on_slug", unique: true
  end

  create_table "calculator_ratings", force: :cascade do |t|
    t.string "calculator_slug", null: false
    t.datetime "created_at", null: false
    t.string "direction", null: false
    t.string "ip_hash", null: false
    t.integer "score"
    t.datetime "updated_at", null: false
    t.index ["calculator_slug", "ip_hash"], name: "index_calculator_ratings_on_calculator_slug_and_ip_hash", unique: true
    t.index ["calculator_slug"], name: "index_calculator_ratings_on_calculator_slug"
  end

  create_table "contact_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "ip_address"
    t.text "message", null: false
    t.string "name", null: false
    t.boolean "read", default: false, null: false
    t.string "subject", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_contact_messages_on_email"
    t.index ["read", "created_at"], name: "index_contact_messages_on_read_and_created_at"
  end

  create_table "newsletter_subscribers", force: :cascade do |t|
    t.boolean "confirmed", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_newsletter_subscribers_on_lower_email", unique: true
    t.index ["confirmed"], name: "index_newsletter_subscribers_on_confirmed"
  end

  create_table "notes", force: :cascade do |t|
    t.integer "byte_size", null: false
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_notes_on_created_at"
    t.index ["filename"], name: "index_notes_on_filename", unique: true
  end

  create_table "photos", force: :cascade do |t|
    t.integer "byte_size", null: false
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.integer "height"
    t.integer "jpg_quality"
    t.integer "max_dimension"
    t.string "original_filename"
    t.string "tags", default: [], array: true
    t.datetime "updated_at", null: false
    t.integer "width"
    t.index ["created_at"], name: "index_photos_on_created_at"
    t.index ["filename"], name: "index_photos_on_filename", unique: true
    t.index ["tags"], name: "index_photos_on_tags", using: :gin
  end

  create_table "user_formulas", force: :cascade do |t|
    t.string "author_email"
    t.string "author_name", null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.jsonb "formula_json", null: false
    t.string "slug", null: false
    t.string "status", default: "pending"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_user_formulas_on_category"
    t.index ["slug"], name: "index_user_formulas_on_slug", unique: true
    t.index ["status"], name: "index_user_formulas_on_status"
  end
end
