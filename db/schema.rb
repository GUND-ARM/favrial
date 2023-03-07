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

ActiveRecord::Schema[7.0].define(version: 2023_03_07_174427) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "classify_results", force: :cascade do |t|
    t.string "classification"
    t.boolean "result"
    t.boolean "by_ml"
    t.bigint "tweet_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tweet_id"], name: "index_classify_results_on_tweet_id"
    t.index ["user_id"], name: "index_classify_results_on_user_id"
  end

  create_table "credentials", force: :cascade do |t|
    t.string "token"
    t.integer "expires_at"
    t.boolean "expires"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "refresh_token"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_credentials_on_user_id"
  end

  create_table "tweets", force: :cascade do |t|
    t.string "t_id"
    t.text "body"
    t.string "url"
    t.text "raw_json"
    t.string "media_type"
    t.string "classification"
    t.boolean "classified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_media_url"
    t.bigint "user_id"
    t.index ["created_at"], name: "index_tweets_on_created_at"
    t.index ["user_id"], name: "index_tweets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "name"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "protected"
    t.string "location"
    t.string "url"
    t.string "description"
    t.string "profile_image_url"
  end

  add_foreign_key "credentials", "users"
end
