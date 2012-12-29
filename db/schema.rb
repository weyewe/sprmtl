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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121229075312) do

  create_table "banks", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "customers", :force => true do |t|
    t.string   "name"
    t.string   "contact_person"
    t.string   "phone"
    t.string   "mobile"
    t.string   "email"
    t.string   "bbm_pin"
    t.text     "office_address"
    t.text     "delivery_address"
    t.integer  "town_id"
    t.boolean  "is_deleted",       :default => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  create_table "delivery_entries", :force => true do |t|
    t.integer  "sales_item_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "delivery_lost_entries", :force => true do |t|
    t.integer  "sales_item_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "post_production_histories", :force => true do |t|
    t.integer  "sales_item_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "post_production_orders", :force => true do |t|
    t.integer  "sales_item_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "pre_production_histories", :force => true do |t|
    t.integer  "sales_item_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "production_histories", :force => true do |t|
    t.integer  "sales_item_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "production_orders", :force => true do |t|
    t.integer  "sales_item_id"
    t.integer  "creator_id"
    t.integer  "case",                     :default => 1
    t.integer  "quantity"
    t.string   "source_document_entry"
    t.integer  "source_document_entry_id"
    t.string   "source_document"
    t.integer  "source_document_id"
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "sales_entries", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sales_items", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "sales_order_id"
    t.string   "code"
    t.boolean  "is_repeat_order",                                                 :default => false
    t.string   "past_sales_item_id"
    t.integer  "material_id",                                                     :default => 1
    t.boolean  "is_pre_production",                                               :default => false
    t.boolean  "is_production",                                                   :default => false
    t.boolean  "is_post_production",                                              :default => false
    t.boolean  "is_delivered",                                                    :default => false
    t.decimal  "price_per_piece",                  :precision => 11, :scale => 2, :default => 0.0
    t.integer  "quantity"
    t.text     "delivery_address"
    t.text     "description"
    t.date     "requested_deadline"
    t.date     "estimated_internal_deadline"
    t.integer  "number_of_pre_production",                                        :default => 0
    t.integer  "number_of_production",                                            :default => 0
    t.integer  "number_of_post_production",                                       :default => 0
    t.integer  "number_of_delivery",                                              :default => 0
    t.integer  "number_of_sales_return",                                          :default => 0
    t.integer  "number_of_delivery_lost",                                         :default => 0
    t.integer  "number_of_failed_production",                                     :default => 0
    t.integer  "number_of_failed_post_production",                                :default => 0
    t.integer  "pending_production",                                              :default => 0
    t.integer  "pending_post_production",                                         :default => 0
    t.integer  "ready",                                                           :default => 0
    t.integer  "on_delivery",                                                     :default => 0
    t.integer  "fulfilled_order",                                                 :default => 0
    t.datetime "created_at",                                                                         :null => false
    t.datetime "updated_at",                                                                         :null => false
  end

  create_table "sales_orders", :force => true do |t|
    t.integer  "creator_id"
    t.string   "code"
    t.date     "order_date"
    t.integer  "payment_term",                                      :default => 2
    t.decimal  "downpayment_amount", :precision => 11, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
  end

  create_table "sales_return_entries", :force => true do |t|
    t.integer  "sales_item_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
