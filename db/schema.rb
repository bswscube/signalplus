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

ActiveRecord::Schema.define(version: 20170107212800) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "brands", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.bigint   "streaming_tweet_pid"
    t.boolean  "polling_tweets",        default: false
    t.string   "tz",                    default: "America/New_York", null: false
    t.datetime "deleted_at"
    t.boolean  "accepted_terms_of_use", default: false
    t.index ["polling_tweets"], name: "index_brands_on_polling_tweets", using: :btree
    t.index ["streaming_tweet_pid"], name: "index_brands_on_streaming_tweet_pid", using: :btree
  end

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "brand_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "encrypted_token"
    t.string   "encrypted_secret"
    t.string   "user_name"
    t.string   "profile_image_url"
    t.datetime "deleted_at"
    t.index ["brand_id"], name: "index_identities_on_brand_id", using: :btree
    t.index ["provider", "uid", "deleted_at"], name: "index_identities_on_provider_and_uid_and_deleted_at", using: :btree
    t.index ["user_id"], name: "index_identities_on_user_id", using: :btree
  end

  create_table "listen_signals", force: :cascade do |t|
    t.integer  "brand_id"
    t.integer  "identity_id"
    t.text     "name"
    t.datetime "expiration_date"
    t.boolean  "active",          default: false, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "signal_type"
    t.datetime "deleted_at"
    t.index ["brand_id"], name: "index_listen_signals_on_brand_id", using: :btree
    t.index ["deleted_at"], name: "index_listen_signals_on_deleted_at", using: :btree
    t.index ["identity_id"], name: "index_listen_signals_on_identity_id", using: :btree
    t.index ["name", "deleted_at"], name: "index_listen_signals_on_name_and_deleted_at", unique: true, using: :btree
  end

  create_table "payment_handlers", force: :cascade do |t|
    t.integer  "brand_id"
    t.string   "provider"
    t.string   "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_payment_handlers_on_brand_id", using: :btree
    t.index ["token"], name: "index_payment_handlers_on_token", using: :btree
  end

  create_table "promotional_tweets", force: :cascade do |t|
    t.text     "message"
    t.integer  "listen_signal_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.bigint   "tweet_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_promotional_tweets_on_deleted_at", using: :btree
    t.index ["listen_signal_id"], name: "index_promotional_tweets_on_listen_signal_id", using: :btree
  end

  create_table "response_groups", force: :cascade do |t|
    t.integer  "listen_signal_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_response_groups_on_deleted_at", using: :btree
    t.index ["listen_signal_id"], name: "index_response_groups_on_listen_signal_id", using: :btree
  end

  create_table "responses", force: :cascade do |t|
    t.text     "message"
    t.string   "response_type"
    t.integer  "response_group_id"
    t.datetime "expiration_date"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "priority"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_responses_on_deleted_at", using: :btree
    t.index ["response_group_id"], name: "index_responses_on_response_group_id", using: :btree
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.integer  "amount"
    t.string   "name"
    t.integer  "number_of_messages"
    t.string   "currency"
    t.string   "provider"
    t.string   "provider_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "description",        default: ""
    t.string   "reference",                       null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "brand_id"
    t.integer  "subscription_plan_id"
    t.string   "provider"
    t.string   "token"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.datetime "canceled_at"
    t.datetime "trial_end"
    t.boolean  "trial",                  default: true
    t.datetime "deleted_at"
    t.integer  "lock_version",           default: 0
    t.datetime "will_be_deactivated_at"
    t.index ["brand_id", "deleted_at"], name: "index_subscriptions_on_brand_id_and_deleted_at", unique: true, using: :btree
    t.index ["canceled_at"], name: "index_subscriptions_on_canceled_at", using: :btree
    t.index ["subscription_plan_id"], name: "index_subscriptions_on_subscription_plan_id", using: :btree
    t.index ["token"], name: "index_subscriptions_on_token", unique: true, using: :btree
    t.index ["trial"], name: "index_subscriptions_on_trial", using: :btree
  end

  create_table "twitter_direct_message_trackers", force: :cascade do |t|
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.bigint   "last_recorded_tweet_id", default: 1
    t.bigint   "since_id",               default: 1
    t.bigint   "max_id"
    t.integer  "brand_id"
    t.index ["brand_id"], name: "index_twitter_direct_message_trackers_on_brand_id", unique: true, using: :btree
  end

  create_table "twitter_responses", force: :cascade do |t|
    t.string   "to",                             null: false
    t.date     "date",                           null: false
    t.bigint   "reply_tweet_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.bigint   "request_tweet_id",   default: 0, null: false
    t.integer  "brand_id"
    t.string   "reply_tweet_type"
    t.string   "request_tweet_type"
    t.integer  "listen_signal_id"
    t.integer  "response_id"
    t.index ["brand_id"], name: "index_twitter_responses_on_brand_id", using: :btree
    t.index ["listen_signal_id"], name: "index_twitter_responses_on_listen_signal_id", using: :btree
    t.index ["request_tweet_id", "listen_signal_id"], name: "index_unique_request_tweet_id", unique: true, using: :btree
    t.index ["response_id"], name: "index_twitter_responses_on_response_id", using: :btree
  end

  create_table "twitter_trackers", force: :cascade do |t|
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.bigint   "last_recorded_tweet_id", default: 1
    t.bigint   "since_id",               default: 1
    t.bigint   "max_id"
    t.integer  "brand_id"
    t.index ["brand_id"], name: "index_twitter_trackers_on_brand_id", unique: true, using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "name"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "brand_id"
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.json     "tokens"
    t.boolean  "email_subscription",     default: false
    t.datetime "deleted_at"
    t.index ["brand_id"], name: "index_users_on_brand_id", using: :btree
    t.index ["email", "deleted_at"], name: "index_users_on_email_and_deleted_at", unique: true, using: :btree
    t.index ["provider", "uid", "deleted_at"], name: "index_users_on_provider_and_uid_and_deleted_at", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "identities", "brands"
  add_foreign_key "identities", "users"
  add_foreign_key "listen_signals", "brands"
  add_foreign_key "listen_signals", "identities"
  add_foreign_key "promotional_tweets", "listen_signals"
  add_foreign_key "response_groups", "listen_signals"
  add_foreign_key "responses", "response_groups"
  add_foreign_key "twitter_direct_message_trackers", "brands"
  add_foreign_key "twitter_responses", "brands"
  add_foreign_key "twitter_trackers", "brands"
  add_foreign_key "users", "brands"
end
