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

ActiveRecord::Schema.define(version: 20180222195941) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

  create_table "field_options", force: :cascade do |t|
    t.bigint "field_id"
    t.bigint "option_value_id"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["field_id"], name: "index_field_options_on_field_id"
    t.index ["option_value_id"], name: "index_field_options_on_option_value_id"
  end

  create_table "fields", force: :cascade do |t|
    t.string "name", null: false
    t.string "input", null: false
    t.string "label", null: false
    t.string "global_registry_attribute"
    t.string "adobe_campaign_attribute"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "placeholder"
  end

  create_table "form_fields", force: :cascade do |t|
    t.uuid "form_id", null: false
    t.bigint "field_id"
    t.string "label"
    t.string "help"
    t.boolean "required", default: false
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "placeholder"
    t.index ["field_id"], name: "index_form_fields_on_field_id"
    t.index ["form_id"], name: "index_form_fields_on_form_id"
  end

  create_table "forms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "campaign_code"
    t.string "name", null: false
    t.text "title"
    t.text "body"
    t.string "action"
    t.text "success"
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "style", default: "basic", null: false
    t.string "redirect_url"
    t.boolean "use_recaptcha", default: false
    t.string "recaptcha_key"
    t.string "recaptcha_secret"
    t.index ["created_by_id"], name: "index_forms_on_created_by_id"
  end

  create_table "option_values", force: :cascade do |t|
    t.string "name"
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.uuid "sso_guid"
    t.string "username"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.boolean "has_access", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
