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

ActiveRecord::Schema.define(:version => 20130203140432) do

  create_table "banks", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cash_accounts", :force => true do |t|
    t.integer  "case",        :default => 1
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.text     "address"
    t.string   "phone"
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
    t.boolean  "is_deleted",                                           :default => false
    t.datetime "created_at",                                                              :null => false
    t.datetime "updated_at",                                                              :null => false
    t.decimal  "outstanding_payment",   :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "remaining_downpayment", :precision => 12, :scale => 2, :default => 0.0
  end

  create_table "deliveries", :force => true do |t|
    t.string   "code"
    t.integer  "creator_id"
    t.integer  "customer_id"
    t.text     "delivery_address"
    t.date     "delivery_date"
    t.boolean  "is_confirmed",     :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.boolean  "is_finalized",     :default => false
    t.integer  "finalizer_id"
    t.datetime "finalized_at"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  create_table "delivery_entries", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "sales_item_id"
    t.integer  "delivery_id"
    t.string   "code"
    t.integer  "quantity_sent",                                           :default => 0
    t.decimal  "quantity_sent_weight",      :precision => 7, :scale => 2, :default => 0.0
    t.integer  "quantity_confirmed",                                      :default => 0
    t.integer  "quantity_returned",                                       :default => 0
    t.decimal  "quantity_returned_weight",  :precision => 7, :scale => 2, :default => 0.0
    t.integer  "quantity_lost",                                           :default => 0
    t.boolean  "is_confirmed",                                            :default => false
    t.boolean  "is_finalized",                                            :default => false
    t.datetime "created_at",                                                                 :null => false
    t.datetime "updated_at",                                                                 :null => false
    t.decimal  "quantity_confirmed_weight", :precision => 7, :scale => 2, :default => 0.0
    t.integer  "entry_case"
  end

  create_table "delivery_lost_entries", :force => true do |t|
    t.integer  "sales_item_id"
    t.integer  "creator_id"
    t.integer  "delivery_lost_id"
    t.integer  "delivery_entry_id"
    t.integer  "is_confirmed",      :default => 0
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "delivery_losts", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "delivery_id"
    t.string   "code"
    t.boolean  "is_confirmed", :default => false
    t.integer  "confirmer_id"
    t.integer  "confirmed_at"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "downpayment_histories", :force => true do |t|
    t.integer  "payment_id"
    t.integer  "customer_id"
    t.integer  "creator_id"
    t.decimal  "amount",      :precision => 12, :scale => 2, :default => 0.0
    t.integer  "case",                                       :default => 1
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
  end

  create_table "employees", :force => true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "mobile"
    t.string   "email"
    t.string   "bbm_pin"
    t.text     "address"
    t.boolean  "is_deleted", :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "guarantee_return_entries", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "sales_item_id"
    t.integer  "guarantee_return_id"
    t.string   "code"
    t.integer  "quantity_for_post_production",                               :default => 0
    t.decimal  "weight_for_post_production",   :precision => 7, :scale => 2, :default => 0.0
    t.integer  "quantity_for_production",                                    :default => 0
    t.decimal  "weight_for_production",        :precision => 7, :scale => 2, :default => 0.0
    t.boolean  "is_confirmed",                                               :default => false
    t.datetime "created_at",                                                                    :null => false
    t.datetime "updated_at",                                                                    :null => false
  end

  create_table "guarantee_returns", :force => true do |t|
    t.string   "code"
    t.date     "receival_date"
    t.integer  "creator_id"
    t.integer  "customer_id"
    t.boolean  "is_confirmed",  :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "invoice_payments", :force => true do |t|
    t.integer  "invoice_id"
    t.integer  "payment_id"
    t.integer  "creator_id"
    t.decimal  "amount_paid",  :precision => 11, :scale => 2, :default => 0.0
    t.boolean  "is_confirmed",                                :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
  end

  create_table "invoices", :force => true do |t|
    t.integer  "delivery_id"
    t.integer  "creator_id"
    t.integer  "customer_id"
    t.string   "code"
    t.decimal  "amount_payable",     :precision => 11, :scale => 2, :default => 0.0
    t.date     "due_date"
    t.boolean  "is_confirmed",                                      :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.boolean  "is_finalized",                                      :default => false
    t.boolean  "is_paid",                                           :default => false
    t.integer  "paid_declarator_id"
    t.datetime "paid_at"
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
  end

  create_table "item_receival_entries", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "sales_item_id"
    t.integer  "item_receival_id"
    t.string   "code"
    t.integer  "quantity"
    t.boolean  "is_confirmed",     :default => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  create_table "item_receivals", :force => true do |t|
    t.string   "code"
    t.date     "receival_date"
    t.integer  "creator_id"
    t.integer  "customer_id"
    t.boolean  "is_confirmed",  :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "materials", :force => true do |t|
    t.string   "name"
    t.boolean  "is_active",  :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "code"
  end

  create_table "payments", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "cash_account_id"
    t.integer  "customer_id"
    t.string   "code"
    t.decimal  "amount_paid",                 :precision => 11, :scale => 2, :default => 0.0
    t.integer  "payment_method"
    t.boolean  "is_confirmed",                                               :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.text     "note"
    t.datetime "created_at",                                                                    :null => false
    t.datetime "updated_at",                                                                    :null => false
    t.decimal  "downpayment_addition_amount", :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "downpayment_usage_amount",    :precision => 12, :scale => 2, :default => 0.0
  end

  create_table "post_production_histories", :force => true do |t|
    t.integer  "sales_item_id"
    t.integer  "creator_id"
    t.integer  "processed_quantity"
    t.integer  "ok_quantity"
    t.integer  "broken_quantity"
    t.decimal  "ok_weight",                              :precision => 7, :scale => 2, :default => 0.0
    t.decimal  "broken_weight",                          :precision => 7, :scale => 2, :default => 0.0
    t.date     "start_date"
    t.date     "finish_date"
    t.boolean  "is_confirmed",                                                         :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.datetime "created_at",                                                                              :null => false
    t.datetime "updated_at",                                                                              :null => false
    t.integer  "bad_source_quantity",                                                  :default => 0
    t.decimal  "bad_source_weight",                      :precision => 7, :scale => 2, :default => 0.0
    t.integer  "subcription_post_production_history_id"
  end

  create_table "post_production_orders", :force => true do |t|
    t.integer  "sales_item_id"
    t.integer  "creator_id"
    t.integer  "case",                      :default => 2
    t.integer  "quantity"
    t.string   "source_document_entry"
    t.integer  "source_document_entry_id"
    t.string   "source_document"
    t.integer  "source_document_id"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "sales_item_subcription_id"
    t.integer  "template_sales_item_id"
  end

  create_table "post_production_results", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pre_production_histories", :force => true do |t|
    t.integer  "sales_item_id"
    t.integer  "creator_id"
    t.integer  "processed_quantity"
    t.integer  "ok_quantity"
    t.integer  "broken_quantity"
    t.date     "start_date"
    t.date     "finish_date"
    t.boolean  "is_confirmed",                          :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.integer  "subcription_pre_production_history_id"
  end

  create_table "pre_production_results", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "production_histories", :force => true do |t|
    t.integer  "sales_item_id"
    t.integer  "creator_id"
    t.integer  "processed_quantity"
    t.integer  "ok_quantity"
    t.integer  "broken_quantity"
    t.integer  "repairable_quantity"
    t.decimal  "ok_weight",                         :precision => 7, :scale => 2, :default => 0.0
    t.decimal  "broken_weight",                     :precision => 7, :scale => 2, :default => 0.0
    t.decimal  "repairable_weight",                 :precision => 7, :scale => 2, :default => 0.0
    t.date     "start_date"
    t.date     "finish_date"
    t.boolean  "is_confirmed",                                                    :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.datetime "created_at",                                                                         :null => false
    t.datetime "updated_at",                                                                         :null => false
    t.decimal  "ok_tap_weight",                     :precision => 7, :scale => 2, :default => 0.0
    t.decimal  "repairable_tap_weight",             :precision => 7, :scale => 2, :default => 0.0
    t.integer  "subcription_production_history_id"
  end

  create_table "production_orders", :force => true do |t|
    t.integer  "sales_item_id"
    t.integer  "creator_id"
    t.integer  "case",                      :default => 1
    t.integer  "quantity"
    t.string   "source_document_entry"
    t.integer  "source_document_entry_id"
    t.string   "source_document"
    t.integer  "source_document_id"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "sales_item_subcription_id"
    t.integer  "template_sales_item_id"
  end

  create_table "production_repair_results", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "production_results", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "responsibilities", :force => true do |t|
    t.integer  "entry_id"
    t.integer  "case"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name",        :null => false
    t.string   "title",       :null => false
    t.text     "description", :null => false
    t.text     "the_role",    :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "sales_entries", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sales_invoice_entries", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sales_invoices", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sales_item_subcriptions", :force => true do |t|
    t.integer  "template_sales_item_id"
    t.integer  "customer_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "sales_items", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "sales_order_id"
    t.string   "code"
    t.boolean  "is_repeat_order",                                                   :default => false
    t.string   "past_sales_item_id"
    t.integer  "material_id"
    t.boolean  "is_pre_production",                                                 :default => false
    t.boolean  "is_production",                                                     :default => false
    t.boolean  "is_post_production",                                                :default => false
    t.boolean  "is_delivered",                                                      :default => false
    t.decimal  "weight_per_piece",                   :precision => 7,  :scale => 2, :default => 0.0
    t.integer  "quantity"
    t.text     "delivery_address"
    t.boolean  "is_sales_order_delivery_address",                                   :default => false
    t.string   "name"
    t.text     "description"
    t.date     "requested_deadline"
    t.date     "estimated_internal_deadline"
    t.integer  "number_of_pre_production",                                          :default => 0
    t.integer  "number_of_production",                                              :default => 0
    t.integer  "number_of_post_production",                                         :default => 0
    t.integer  "number_of_delivery",                                                :default => 0
    t.integer  "number_of_sales_return",                                            :default => 0
    t.integer  "number_of_delivery_lost",                                           :default => 0
    t.integer  "number_of_failed_production",                                       :default => 0
    t.integer  "number_of_failed_post_production",                                  :default => 0
    t.integer  "pending_production",                                                :default => 0
    t.integer  "pending_post_production",                                           :default => 0
    t.integer  "ready",                                                             :default => 0
    t.integer  "on_delivery",                                                       :default => 0
    t.integer  "fulfilled_order",                                                   :default => 0
    t.boolean  "is_confirmed",                                                      :default => false
    t.boolean  "is_deleted",                                                        :default => false
    t.datetime "created_at",                                                                           :null => false
    t.datetime "updated_at",                                                                           :null => false
    t.decimal  "pre_production_price",               :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "production_price",                   :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "post_production_price",              :precision => 12, :scale => 2, :default => 0.0
    t.boolean  "is_pricing_by_weight",                                              :default => false
    t.boolean  "is_pending_pricing",                                                :default => false
    t.integer  "pending_guarantee_return_delivery",                                 :default => 0
    t.integer  "pending_bad_source_delivery",                                       :default => 0
    t.integer  "pending_technical_failure_delivery",                                :default => 0
    t.integer  "number_of_guarantee_return",                                        :default => 0
    t.integer  "number_of_bad_source",                                              :default => 0
    t.integer  "number_of_technical_failure",                                       :default => 0
    t.integer  "template_sales_item_id"
    t.integer  "customer_id"
    t.integer  "sales_item_subcription_id"
    t.integer  "case",                                                              :default => 1
    t.boolean  "is_canceled",                                                       :default => false
  end

  create_table "sales_orders", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "customer_id"
    t.string   "code"
    t.date     "order_date"
    t.integer  "payment_term",                                      :default => 2
    t.decimal  "downpayment_amount", :precision => 11, :scale => 2, :default => 0.0
    t.boolean  "is_confirmed",                                      :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.boolean  "is_deleted",                                        :default => false
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
  end

  create_table "sales_return_entries", :force => true do |t|
    t.integer  "sales_item_id"
    t.integer  "creator_id"
    t.integer  "sales_return_id"
    t.integer  "delivery_entry_id"
    t.integer  "quantity_for_post_production",                               :default => 0
    t.decimal  "weight_for_post_production",   :precision => 7, :scale => 2, :default => 0.0
    t.integer  "quantity_for_production",                                    :default => 0
    t.decimal  "weight_for_production",        :precision => 7, :scale => 2, :default => 0.0
    t.integer  "is_confirmed",                                               :default => 0
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.datetime "created_at",                                                                  :null => false
    t.datetime "updated_at",                                                                  :null => false
  end

  create_table "sales_returns", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "delivery_id"
    t.string   "code"
    t.boolean  "is_confirmed", :default => false
    t.integer  "confirmer_id"
    t.integer  "confirmed_at"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "subcription_post_production_histories", :force => true do |t|
    t.integer  "sales_item_subcription_id"
    t.integer  "sales_item_id"
    t.integer  "creator_id"
    t.integer  "processed_quantity",                                      :default => 0
    t.integer  "ok_quantity",                                             :default => 0
    t.integer  "broken_quantity",                                         :default => 0
    t.decimal  "ok_weight",                 :precision => 7, :scale => 2, :default => 0.0
    t.decimal  "broken_weight",             :precision => 7, :scale => 2, :default => 0.0
    t.date     "start_date"
    t.date     "finish_date"
    t.boolean  "is_confirmed",                                            :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.integer  "bad_source_quantity",                                     :default => 0
    t.decimal  "bad_source_weight",         :precision => 7, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                                 :null => false
    t.datetime "updated_at",                                                                 :null => false
  end

  create_table "subcription_pre_production_histories", :force => true do |t|
    t.integer  "sales_item_subcription_id"
    t.integer  "creator_id"
    t.integer  "processed_quantity",        :default => 0
    t.integer  "ok_quantity",               :default => 0
    t.integer  "broken_quantity",           :default => 0
    t.date     "start_date"
    t.date     "finish_date"
    t.boolean  "is_confirmed",              :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  create_table "subcription_production_histories", :force => true do |t|
    t.integer  "sales_item_subcription_id"
    t.integer  "sales_item_id"
    t.integer  "creator_id"
    t.integer  "processed_quantity",                                      :default => 0
    t.integer  "ok_quantity",                                             :default => 0
    t.integer  "broken_quantity",                                         :default => 0
    t.integer  "repairable_quantity",                                     :default => 0
    t.decimal  "ok_weight",                 :precision => 7, :scale => 2, :default => 0.0
    t.decimal  "broken_weight",             :precision => 7, :scale => 2, :default => 0.0
    t.decimal  "repairable_weight",         :precision => 7, :scale => 2, :default => 0.0
    t.date     "start_date"
    t.date     "finish_date"
    t.boolean  "is_confirmed",                                            :default => false
    t.integer  "confirmer_id"
    t.datetime "confirmed_at"
    t.decimal  "ok_tap_weight",             :precision => 7, :scale => 2, :default => 0.0
    t.decimal  "repairable_tap_weight",     :precision => 7, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                                 :null => false
    t.datetime "updated_at",                                                                 :null => false
  end

  create_table "template_sales_items", :force => true do |t|
    t.string   "code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "role_id"
    t.string   "name"
    t.string   "username"
    t.string   "login"
    t.boolean  "is_deleted",             :default => false
    t.boolean  "is_main_user",           :default => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
