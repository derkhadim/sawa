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

ActiveRecord::Schema[7.2].define(version: 2026_06_27_221936) do
  create_table "agencies", force: :cascade do |t|
    t.string "name", null: false
    t.string "address"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "apartments", force: :cascade do |t|
    t.string "number", null: false
    t.integer "floor"
    t.decimal "rent_amount", precision: 10, scale: 2, null: false
    t.string "status", default: "free", null: false
    t.integer "building_id", null: false
    t.integer "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "photos"
    t.boolean "visible", default: false, null: false
    t.index ["building_id", "number"], name: "index_apartments_on_building_id_and_number", unique: true
    t.index ["building_id"], name: "index_apartments_on_building_id"
    t.index ["tenant_id"], name: "index_apartments_on_tenant_id"
  end

  create_table "buildings", force: :cascade do |t|
    t.string "name", null: false
    t.string "address", null: false
    t.string "neighborhood"
    t.string "commune"
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.integer "owner_id", null: false
    t.integer "agency_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "photo"
    t.index ["agency_id"], name: "index_buildings_on_agency_id"
    t.index ["owner_id"], name: "index_buildings_on_owner_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "publication_id", null: false
    t.integer "user_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publication_id"], name: "index_comments_on_publication_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "conversation_participants", force: :cascade do |t|
    t.integer "conversation_id", null: false
    t.integer "user_id", null: false
    t.datetime "last_read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "user_id"], name: "index_conversation_participants_on_conversation_id_and_user_id", unique: true
    t.index ["conversation_id"], name: "index_conversation_participants_on_conversation_id"
    t.index ["user_id"], name: "index_conversation_participants_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "incidents", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.string "status", default: "open", null: false
    t.integer "apartment_id", null: false
    t.integer "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "provider_id"
    t.index ["apartment_id"], name: "index_incidents_on_apartment_id"
    t.index ["provider_id"], name: "index_incidents_on_provider_id"
    t.index ["tenant_id"], name: "index_incidents_on_tenant_id"
  end

  create_table "likes", force: :cascade do |t|
    t.integer "publication_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publication_id", "user_id"], name: "index_likes_on_publication_id_and_user_id", unique: true
    t.index ["publication_id"], name: "index_likes_on_publication_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "conversation_id", null: false
    t.integer "sender_id", null: false
    t.text "body", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "move_out_notices", force: :cascade do |t|
    t.date "move_out_date", null: false
    t.integer "apartment_id", null: false
    t.integer "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["apartment_id"], name: "index_move_out_notices_on_apartment_id"
    t.index ["tenant_id"], name: "index_move_out_notices_on_tenant_id"
  end

  create_table "owners", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.date "paid_at"
    t.date "due_date", null: false
    t.string "status", default: "pending", null: false
    t.integer "month", null: false
    t.integer "year", null: false
    t.string "reference"
    t.integer "apartment_id", null: false
    t.integer "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "proof"
    t.string "payment_method"
    t.index ["apartment_id", "month", "year"], name: "index_payments_on_apartment_id_and_month_and_year", unique: true
    t.index ["apartment_id"], name: "index_payments_on_apartment_id"
    t.index ["tenant_id"], name: "index_payments_on_tenant_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "resource", null: false
    t.string "action", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resource", "action"], name: "index_permissions_on_resource_and_action", unique: true
  end

  create_table "providers", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone", null: false
    t.string "trade", null: false
    t.integer "agency_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agency_id"], name: "index_providers_on_agency_id"
  end

  create_table "publications", force: :cascade do |t|
    t.text "content", null: false
    t.integer "building_id", null: false
    t.integer "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "likes_count", default: 0, null: false
    t.integer "comments_count", default: 0, null: false
    t.index ["building_id"], name: "index_publications_on_building_id"
    t.index ["tenant_id"], name: "index_publications_on_tenant_id"
  end

  create_table "role_permissions", force: :cascade do |t|
    t.integer "role_id", null: false
    t.integer "permission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id", "permission_id"], name: "index_role_permissions_on_role_id_and_permission_id", unique: true
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.integer "agency_id"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agency_id"], name: "index_roles_on_agency_id"
    t.index ["name", "agency_id"], name: "index_roles_on_name_and_agency_id", unique: true
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "phone", null: false
    t.string "password_digest", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "role", default: "tenant", null: false
    t.integer "agency_id"
    t.integer "building_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "profile_photo"
    t.string "cover_photo"
    t.integer "rating"
    t.index ["agency_id"], name: "index_users_on_agency_id"
    t.index ["building_id"], name: "index_users_on_building_id"
    t.index ["phone"], name: "index_users_on_phone", unique: true
  end

  add_foreign_key "apartments", "buildings"
  add_foreign_key "apartments", "users", column: "tenant_id"
  add_foreign_key "buildings", "agencies"
  add_foreign_key "buildings", "owners"
  add_foreign_key "comments", "publications"
  add_foreign_key "comments", "users"
  add_foreign_key "conversation_participants", "conversations"
  add_foreign_key "conversation_participants", "users"
  add_foreign_key "incidents", "apartments"
  add_foreign_key "incidents", "providers"
  add_foreign_key "incidents", "users", column: "tenant_id"
  add_foreign_key "likes", "publications"
  add_foreign_key "likes", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "move_out_notices", "apartments"
  add_foreign_key "move_out_notices", "users", column: "tenant_id"
  add_foreign_key "payments", "apartments"
  add_foreign_key "payments", "users", column: "tenant_id"
  add_foreign_key "providers", "agencies"
  add_foreign_key "publications", "buildings"
  add_foreign_key "publications", "users", column: "tenant_id"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "roles", "agencies"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "users", "agencies"
  add_foreign_key "users", "buildings"
end
