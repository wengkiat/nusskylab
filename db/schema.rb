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

ActiveRecord::Schema.define(version: 20150801154150) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "admins", ["user_id"], name: "index_admins_on_user_id", using: :btree

  create_table "advisers", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "advisers", ["user_id"], name: "index_advisers_on_user_id", using: :btree

  create_table "evaluatings", force: :cascade do |t|
    t.integer "evaluator_id", null: false
    t.integer "evaluated_id", null: false
  end

  add_index "evaluatings", ["evaluated_id"], name: "index_evaluatings_on_evaluated_id", using: :btree
  add_index "evaluatings", ["evaluator_id"], name: "index_evaluatings_on_evaluator_id", using: :btree

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "evaluating_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "feedbacks", ["evaluating_id"], name: "index_feedbacks_on_evaluating_id", using: :btree
  add_index "feedbacks", ["team_id"], name: "index_feedbacks_on_team_id", using: :btree

  create_table "mentors", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "mentors", ["user_id"], name: "index_mentors_on_user_id", using: :btree

  create_table "milestones", force: :cascade do |t|
    t.datetime "submission_deadline",      default: '2015-06-28 15:26:03', null: false
    t.string   "name"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.datetime "peer_evaluation_deadline", default: '2015-06-28 15:26:03', null: false
  end

  create_table "peer_evaluations", force: :cascade do |t|
    t.text     "public_content"
    t.text     "private_content"
    t.boolean  "published"
    t.integer  "team_id"
    t.integer  "submission_id"
    t.integer  "adviser_id"
    t.string   "owner_type",      default: "teams"
    t.datetime "created_at",      default: '2015-06-22 16:15:36', null: false
    t.datetime "updated_at",      default: '2015-06-22 16:15:36', null: false
  end

  add_index "peer_evaluations", ["adviser_id"], name: "index_peer_evaluations_on_adviser_id", using: :btree
  add_index "peer_evaluations", ["submission_id"], name: "index_peer_evaluations_on_submission_id", using: :btree
  add_index "peer_evaluations", ["team_id"], name: "index_peer_evaluations_on_team_id", using: :btree

  create_table "questions", force: :cascade do |t|
    t.integer  "feedback_id"
    t.integer  "peer_evaluation_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "questions", ["feedback_id"], name: "index_questions_on_feedback_id", using: :btree
  add_index "questions", ["peer_evaluation_id"], name: "index_questions_on_peer_evaluation_id", using: :btree

  create_table "students", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "team_id"
  end

  add_index "students", ["team_id"], name: "index_students_on_team_id", using: :btree
  add_index "students", ["user_id"], name: "index_students_on_user_id", using: :btree

  create_table "submissions", force: :cascade do |t|
    t.integer  "milestone_id",                 null: false
    t.integer  "team_id",                      null: false
    t.boolean  "published",    default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "video_link"
    t.text     "read_me"
    t.text     "project_log"
  end

  add_index "submissions", ["milestone_id"], name: "index_submissions_on_milestone_id", using: :btree
  add_index "submissions", ["team_id"], name: "index_submissions_on_team_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.integer  "adviser_id"
    t.integer  "mentor_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "team_name"
    t.string   "project_level"
  end

  add_index "teams", ["adviser_id"], name: "index_teams_on_adviser_id", using: :btree
  add_index "teams", ["mentor_id"], name: "index_teams_on_mentor_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "provider",               default: "NUS", null: false
    t.string   "uid",                                    null: false
    t.string   "user_name",                              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "admins", "users"
  add_foreign_key "advisers", "users"
  add_foreign_key "evaluatings", "teams", column: "evaluated_id"
  add_foreign_key "evaluatings", "teams", column: "evaluator_id"
  add_foreign_key "feedbacks", "evaluatings"
  add_foreign_key "feedbacks", "teams"
  add_foreign_key "mentors", "users"
  add_foreign_key "peer_evaluations", "advisers"
  add_foreign_key "peer_evaluations", "submissions"
  add_foreign_key "peer_evaluations", "teams"
  add_foreign_key "questions", "feedbacks"
  add_foreign_key "questions", "peer_evaluations"
  add_foreign_key "students", "teams"
  add_foreign_key "students", "users"
  add_foreign_key "submissions", "milestones"
  add_foreign_key "submissions", "teams"
  add_foreign_key "teams", "advisers"
  add_foreign_key "teams", "mentors"
end
