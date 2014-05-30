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

ActiveRecord::Schema.define(version: 20140528164554) do

  create_table "admins", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "configuration_parameters", force: true do |t|
    t.string   "name"
    t.text     "value"
    t.integer  "project_id"
    t.integer  "stage_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "prompt_on_deploy", default: 0
  end

  add_index "configuration_parameters", ["project_id", "type", "name"], name: "ix_projectid_type_name", using: :btree
  add_index "configuration_parameters", ["stage_id", "type", "name"], name: "ix_stageid_type_name", using: :btree

  create_table "deployments", force: true do |t|
    t.string   "task"
    t.text     "log"
    t.integer  "stage_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
    t.text     "description"
    t.integer  "user_id"
    t.string   "excluded_host_ids", limit: 1024
    t.string   "revision"
    t.integer  "pid"
    t.string   "status",                         default: "running"
  end

  add_index "deployments", ["stage_id", "created_at"], name: "idx_deployments_sid_created", using: :btree

  create_table "deployments_roles", id: false, force: true do |t|
    t.integer "deployment_id"
    t.integer "role_id"
  end

  add_index "deployments_roles", ["role_id", "deployment_id"], name: "idx_deployments_roles_rid_did", using: :btree
  add_index "deployments_roles", ["role_id"], name: "deployments_roles_role_id", using: :btree

  create_table "hosts", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hosts", ["name"], name: "idx_hosts_name", using: :btree

  create_table "play_evolutions", force: true do |t|
    t.string    "hash",          null: false
    t.timestamp "applied_at",    null: false
    t.text      "apply_script"
    t.text      "revert_script"
    t.string    "state"
    t.text      "last_problem"
  end

  create_table "project_configurations", force: true do |t|
  end

  create_table "projects", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "template"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipe_versions", force: true do |t|
    t.integer  "recipe_id"
    t.integer  "version"
    t.string   "name"
    t.text     "body"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipes", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version",     default: 1
  end

  add_index "recipes", ["name"], name: "idx_recipes_name", using: :btree

  create_table "recipes_stages", id: false, force: true do |t|
    t.integer "recipe_id"
    t.integer "stage_id"
  end

  add_index "recipes_stages", ["stage_id"], name: "recipes_stages_stage_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "stage_id"
    t.integer  "host_id"
    t.integer  "primary",    default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "no_release", default: 0
    t.integer  "ssh_port"
    t.integer  "no_symlink", default: 0
  end

  add_index "roles", ["stage_id", "name", "host_id"], name: "idx_roles_stage_id_name_hots_id", using: :btree
  add_index "roles", ["stage_id"], name: "roles_index_1", using: :btree

  create_table "stage_configurations", force: true do |t|
  end

  create_table "stages", force: true do |t|
    t.string   "name"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "alert_emails"
    t.integer  "locked_by_deployment_id"
    t.integer  "locked",                  default: 0
  end

  add_index "stages", ["project_id", "name"], name: "idx_stages_pid_name", using: :btree

  create_table "users", force: true do |t|
    t.string   "login",                  default: "",    null: false
    t.string   "email",                  default: "",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "admin",                  default: 0
    t.string   "time_zone",              default: "UTC"
    t.datetime "disabled"
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "migrated",               default: true,  null: false
  end

  add_index "users", ["disabled"], name: "index_users_on_disabled", using: :btree
  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
