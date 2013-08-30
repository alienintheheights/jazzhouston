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

ActiveRecord::Schema.define(:version => 20130830231425) do

  create_table "albums", :primary_key => "album_id", :force => true do |t|
    t.string  "title",           :limit => 75, :default => "", :null => false
    t.string  "artist_name",     :limit => 75
    t.integer "musician_id",                   :default => 0,  :null => false
    t.text    "about"
    t.string  "image_url"
    t.string  "related_url"
    t.date    "release_date",                                  :null => false
    t.string  "sort_name",       :limit => 75, :default => "", :null => false
    t.integer "featured_flag",   :limit => 1,  :default => 0,  :null => false
    t.string  "buy_url"
    t.string  "short_about"
    t.integer "html_break_flag",               :default => 0
    t.integer "genre_id"
  end

  add_index "albums", ["featured_flag"], :name => "featured_flag"
  add_index "albums", ["musician_id"], :name => "artist_id"
  add_index "albums", ["title"], :name => "title"

  create_table "article_type", :primary_key => "article_type_id", :force => true do |t|
    t.string "article_type_name", :default => "", :null => false
    t.string "menu_url",          :default => "", :null => false
    t.string "item_url",          :default => "", :null => false
    t.string "edit_url"
  end

  create_table "boards", :primary_key => "board_id", :force => true do |t|
    t.string  "title",                               :default => "",        :null => false
    t.text    "about",         :limit => 2147483647
    t.string  "bg_color",      :limit => 25,         :default => "#FFFFFF", :null => false
    t.string  "link_color",    :limit => 25,         :default => "#FF0000", :null => false
    t.string  "vlink_color",   :limit => 25,         :default => "#000000", :null => false
    t.string  "bg_image"
    t.integer "login_flag",    :limit => 1,          :default => 0,         :null => false
    t.integer "status",                              :default => 1,         :null => false
    t.integer "sort_order",                          :default => 1,         :null => false
    t.integer "featured_flag", :limit => 1,          :default => 0,         :null => false
    t.integer "list_flag",                           :default => 0
  end

  add_index "boards", ["featured_flag"], :name => "featured_flag"

  create_table "content", :primary_key => "content_id", :force => true do |t|
    t.string    "title",                              :default => "",                :null => false
    t.integer   "content_type_id",                    :default => 1,                 :null => false
    t.string    "content_sub_type",    :limit => 75,  :default => "news"
    t.string    "author",              :limit => 125, :default => "Roving Reporter", :null => false
    t.text      "body_text"
    t.datetime  "created_date"
    t.date      "display_date"
    t.boolean   "local_flag",                         :default => false,             :null => false
    t.string    "external_image_url"
    t.string    "thumbnail_image_url"
    t.timestamp "modified_date",                                                     :null => false
    t.integer   "status_id",                          :default => 1,                 :null => false
    t.string    "teaser"
    t.string    "sub_title"
    t.float     "rating",              :limit => 10
    t.string    "related_url"
    t.string    "item_url"
    t.string    "edit_url"
    t.integer   "html_break_flag",     :limit => 1,   :default => 1,                 :null => false
    t.integer   "author_id"
    t.integer   "featured_flag",       :limit => 1,   :default => 0,                 :null => false
    t.string    "photo_file_name"
    t.string    "photo_content_type"
    t.integer   "photo_file_size"
    t.string    "image"
  end

  add_index "content", ["author"], :name => "author"
  add_index "content", ["content_type_id"], :name => "content_type"
  add_index "content", ["title"], :name => "title"

  create_table "event_type", :primary_key => "event_type_id", :force => true do |t|
    t.string "event_type_name", :default => "", :null => false
  end

  add_index "event_type", ["event_type_name"], :name => "event_type_name"

  create_table "events", :primary_key => "event_id", :force => true do |t|
    t.text    "about",                                        :null => false
    t.date    "show_date"
    t.string  "performer",      :limit => 125
    t.integer "venue_id"
    t.integer "event_type_id",                 :default => 0, :null => false
    t.integer "artist_id"
    t.string  "related_url"
    t.integer "day_of_week",                   :default => 0
    t.string  "type_of_steady", :limit => 20
    t.string  "show_time",      :limit => 25
    t.integer "featured_flag",  :limit => 1,   :default => 0, :null => false
    t.integer "jh_pick_flag",   :limit => 1,   :default => 0, :null => false
    t.integer "touring_flag"
    t.integer "jam_flag",                      :default => 0, :null => false
  end

  add_index "events", ["day_of_week"], :name => "day_of_week"
  add_index "events", ["featured_flag"], :name => "featured_flag"
  add_index "events", ["show_date", "event_type_id"], :name => "event_date"

  create_table "genres", :primary_key => "genre_id", :force => true do |t|
    t.string "genre_name"
    t.text   "genre_description", :null => false
  end

  create_table "instruments", :primary_key => "instrument_id", :force => true do |t|
    t.string "instrument_name",  :limit => 75, :default => "", :null => false
    t.string "instrument_group", :limit => 25, :default => "", :null => false
  end

  add_index "instruments", ["instrument_group"], :name => "instrument_group"
  add_index "instruments", ["instrument_name"], :name => "name"

  create_table "message_scores", :primary_key => "message_score_id", :force => true do |t|
    t.integer "user_id",    :null => false
    t.integer "message_id", :null => false
  end

  add_index "message_scores", ["message_id"], :name => "message_scores_msg_idx"
  add_index "message_scores", ["user_id"], :name => "message_scores_user_idx"

  create_table "messages", :primary_key => "message_id", :force => true do |t|
    t.integer  "thread_id",                   :default => 0, :null => false
    t.string   "author"
    t.string   "email"
    t.integer  "user_id",                     :default => 0, :null => false
    t.text     "message_text",                               :null => false
    t.datetime "pdate"
    t.integer  "status",                      :default => 0, :null => false
    t.string   "ip_address",    :limit => 20
    t.integer  "featured_flag", :limit => 1,  :default => 0, :null => false
    t.integer  "rating",                      :default => 0
  end

  add_index "messages", ["featured_flag"], :name => "featured_flag"
  add_index "messages", ["rating"], :name => "rating"
  add_index "messages", ["status"], :name => "status"
  add_index "messages", ["thread_id"], :name => "fkIDX"
  add_index "messages", ["user_id"], :name => "user_id"

  create_table "musician_album", :id => false, :force => true do |t|
    t.integer "album_id",                 :default => 0, :null => false
    t.integer "musician_id",              :default => 0, :null => false
    t.integer "leader_flag", :limit => 1, :default => 0, :null => false
  end

  add_index "musician_album", ["album_id", "musician_id"], :name => "album_id"
  add_index "musician_album", ["leader_flag"], :name => "leader_flag"

  create_table "musician_instrument", :id => false, :force => true do |t|
    t.integer "user_id",       :default => 0, :null => false
    t.integer "instrument_id", :default => 0, :null => false
  end

  add_index "musician_instrument", ["user_id", "instrument_id"], :name => "user_id"

  create_table "poll", :primary_key => "poll_id", :force => true do |t|
    t.string    "title",         :limit => 75, :default => "", :null => false
    t.timestamp "created_date",                                :null => false
    t.integer   "status_id",                   :default => 1,  :null => false
    t.integer   "featured_flag", :limit => 1,  :default => 0,  :null => false
  end

  add_index "poll", ["created_date"], :name => "created_date"
  add_index "poll", ["featured_flag"], :name => "featured_flag"
  add_index "poll", ["status_id"], :name => "status_id"

  create_table "poll_choices", :primary_key => "poll_choice_id", :force => true do |t|
    t.integer "poll_id",               :default => 0,  :null => false
    t.string  "answer",  :limit => 75, :default => "", :null => false
    t.integer "tally",                 :default => 0,  :null => false
    t.integer "rank",                  :default => 1,  :null => false
  end

  add_index "poll_choices", ["poll_id"], :name => "poll_id"
  add_index "poll_choices", ["rank"], :name => "rank"

  create_table "rcr_diffs", :primary_key => "diff_id", :force => true do |t|
    t.text      "about",    :limit => 2147483647
    t.text      "patch",    :limit => 2147483647, :null => false
    t.integer   "drone_id",                       :null => false
    t.timestamp "date",                           :null => false
    t.string    "title",                          :null => false
  end

  create_table "rcr_diffs_comments", :primary_key => "diff_comment_id", :force => true do |t|
    t.integer   "diff_id",     :null => false
    t.integer   "diff_row_id"
    t.timestamp "date",        :null => false
    t.text      "comment",     :null => false
    t.integer   "drone_id",    :null => false
  end

  create_table "rcr_diffs_drones", :primary_key => "drone_id", :force => true do |t|
    t.string "name",             :limit => 150, :null => false
    t.string "alias",            :limit => 50
    t.string "email",            :limit => 150
    t.string "password",         :limit => 20
    t.string "salt"
    t.string "crypted_password"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"
  add_index "sessions", ["updated_at"], :name => "updated_at_idx"

  create_table "status", :primary_key => "status_id", :force => true do |t|
    t.string "status_type", :limit => 20, :default => "", :null => false
  end

  create_table "threads", :primary_key => "thread_id", :force => true do |t|
    t.string    "title",                       :default => "", :null => false
    t.integer   "post_count",                  :default => 0,  :null => false
    t.string    "author"
    t.string    "email"
    t.integer   "user_id",                     :default => 0,  :null => false
    t.datetime  "modified_date"
    t.timestamp "created_date"
    t.integer   "board_id",                    :default => 0,  :null => false
    t.integer   "status",                      :default => 0,  :null => false
    t.integer   "featured_flag",  :limit => 1, :default => 0,  :null => false
    t.integer   "rating",                      :default => 0
    t.integer   "creator_id"
    t.integer   "monologue_flag",              :default => 0
  end

  add_index "threads", ["featured_flag"], :name => "featured_flag"
  add_index "threads", ["status"], :name => "status"
  add_index "threads", ["title"], :name => "titleIDX"
  add_index "threads", ["user_id"], :name => "user_id"

  create_table "user_bans", :primary_key => "user_ban_id", :force => true do |t|
    t.integer   "victim_id",     :default => 0, :null => false
    t.integer   "pariah_id",     :default => 0, :null => false
    t.timestamp "creation_date",                :null => false
  end

  add_index "user_bans", ["victim_id", "pariah_id"], :name => "victim_id"

  create_table "user_status", :id => false, :force => true do |t|
    t.integer   "user_status_id",                :null => false
    t.integer   "user_id",                       :null => false
    t.integer   "total_count",    :default => 1, :null => false
    t.timestamp "create_date",                   :null => false
    t.timestamp "update_date"
  end

  create_table "user_status_message", :primary_key => "status_id", :force => true do |t|
    t.integer   "user_status_id", :null => false
    t.integer   "user_id",        :null => false
    t.timestamp "post_date",      :null => false
    t.text      "status_text",    :null => false
  end

  create_table "users", :primary_key => "user_id", :force => true do |t|
    t.string    "username",                                        :default => "", :null => false
    t.string    "password",                  :limit => 25
    t.string    "fullname"
    t.string    "email"
    t.string    "url"
    t.integer   "forum_status",                                    :default => 1
    t.integer   "local_player_flag",         :limit => 1,          :default => 0,  :null => false
    t.string    "first_name"
    t.string    "last_name"
    t.text      "about_me",                  :limit => 2147483647
    t.string    "gender",                    :limit => 1
    t.timestamp "modified_date",                                                   :null => false
    t.timestamp "created_date",                                                    :null => false
    t.string    "location"
    t.string    "occupation"
    t.string    "home_phone",                :limit => 75
    t.string    "cell_phone",                :limit => 75
    t.string    "business_phone",            :limit => 75
    t.string    "image_url",                 :limit => 75
    t.integer   "editor_flag",               :limit => 1,          :default => 0,  :null => false
    t.integer   "admin_flag",                                      :default => 0
    t.integer   "band_flag",                 :limit => 1,          :default => 0,  :null => false
    t.integer   "status_id",                                       :default => 0,  :null => false
    t.string    "salt",                      :limit => 40
    t.string    "crypted_password",          :limit => 40
    t.datetime  "remember_token_expires_at"
    t.integer   "forum_score"
    t.string    "remember_token",            :limit => 40
    t.string    "image"
    t.string    "favorite_music",            :limit => 1024
    t.string    "favorite_films",            :limit => 1024
    t.integer   "is_band",                                         :default => 0
    t.string    "twitter_name"
    t.string    "hide_email"
  end

  add_index "users", ["local_player_flag"], :name => "local_player_flag"
  add_index "users", ["username"], :name => "username"

  create_table "venue_area", :primary_key => "venue_area_id", :force => true do |t|
    t.string "area_name", :default => "", :null => false
    t.string "region",    :default => "", :null => false
  end

  add_index "venue_area", ["venue_area_id"], :name => "venue_area_id"
  add_index "venue_area", ["venue_area_id"], :name => "venue_area_id_2", :unique => true

  create_table "venues", :primary_key => "venue_id", :force => true do |t|
    t.string  "title",                             :default => "", :null => false
    t.string  "address",            :limit => 125
    t.text    "about"
    t.integer "under_21_flag"
    t.string  "phone",              :limit => 15
    t.integer "status_id",                         :default => 2,  :null => false
    t.string  "map_quest_url"
    t.string  "external_image_url"
    t.string  "related_url"
    t.integer "featured_flag",      :limit => 1,   :default => 0,  :null => false
    t.string  "short_about"
    t.integer "venue_area_id",                     :default => 0,  :null => false
    t.string  "photo_file_name"
    t.string  "photo_content_type"
    t.integer "photo_file_size"
    t.string  "photo"
  end

  add_index "venues", ["featured_flag"], :name => "featured_flag"
  add_index "venues", ["status_id"], :name => "status_id"
  add_index "venues", ["title"], :name => "name"

end
