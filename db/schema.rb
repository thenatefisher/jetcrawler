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

ActiveRecord::Schema.define(:version => 20121227120037) do

  create_table "changes", :force => true do |t|
    t.integer  "source_id"
    t.string   "field"
    t.text     "value"
    t.integer  "conflict_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "target_id"
  end

  create_table "classifiers", :force => true do |t|
    t.string   "target_make"
    t.string   "target_model"
    t.string   "source_make"
    t.string   "source_model"
    t.string   "serial_prefix"
    t.string   "suggested_prefix"
    t.integer  "min_sn"
    t.integer  "max_sn"
    t.integer  "source_id"
    t.boolean  "active"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "field_priorities", :force => true do |t|
    t.string   "field"
    t.integer  "priority"
    t.integer  "source_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "owners", :force => true do |t|
    t.string   "name"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "postal"
    t.string   "country"
    t.integer  "airframe_id"
    t.datetime "start"
    t.datetime "end"
    t.integer  "source_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "sources", :force => true do |t|
    t.string   "name"
    t.string   "label"
    t.datetime "latest"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "targets", :force => true do |t|
    t.string   "make"
    t.string   "model_name"
    t.integer  "ttaf"
    t.integer  "tcaf"
    t.integer  "year"
    t.string   "serial"
    t.integer  "serial_integer"
    t.string   "registration"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "jetdeck_id"
    t.text     "equipment"
    t.string   "location"
    t.text     "avionics"
    t.text     "inspection"
    t.text     "interior"
    t.text     "exterior"
    t.text     "description"
    t.integer  "price"
    t.boolean  "damage"
    t.text     "seller"
  end

  create_table "translations", :force => true do |t|
    t.integer  "target_id"
    t.string   "token"
    t.integer  "source_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
