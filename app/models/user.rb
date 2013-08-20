#
# The User class
# password is encrypted by algorithms within
#
class User < ActiveRecord::Base
  set_primary_key "user_id"
  set_table_name "users"
  has_many :musician_instruments, :dependent => :destroy
  has_many :instruments, :through => :musician_instruments
  has_many :messages
  has_many :user_bans

  # Virtual attribute for the unencrypted password
  attr_accessible :username, :email,  :password_confirmation,  :first_name, :last_name, :about_me,
				  :occupation, :location, :url, :favorite_music, :favorite_films, :home_phone,
				  :cell_phone, :remember_token, :remember_token_expires_at, :image, :image_url


  validates_presence_of     :username, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :username,    :within => 2..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :username, :case_sensitive => false
  before_save :encrypt_password

  #define_index do
  #	indexes first_name
  #	indexes last_name, :sortable => true
  #	indexes username
  #	indexes user_id
  #	indexes local_player_flag
  # end

  # This is the image magick rendering. It will be replaced by paperclip one day.
  file_column :image, :magick => {
		  :versions => {
				  :thumb => {:crop => "1:1", :geometry => "50x50"},
				  :profile => {:crop => "1:1", :geometry => "200x200"},
				  :avatar => {:crop => "1:1", :geometry => "125x125"}
		  }
  }


  # Search class method
  def self.search_users(search_term)
	  User.where("lower(username) like ? or lower(first_name) like ? or lower(last_name) like ? ", search_term, search_term, search_term).order("last_name").select("username, first_name, last_name, user_id")
  end

  # change password class method
  def change_password(username, old_password, new_password)
	u = User.authenticate(username, old_password)
	if (u)
	  u.password = new_password
	  u.save(:validate => false)
	  true
	else
	  false
	end
  end

  #========================
  # Public Model Functions
  #========================


  # checks a reset key hash
  def hash_key
	Digest::SHA1.hexdigest("--#{self.email}--#{self.username}--")
  end

  # simple delete account
  def delete_account
	self.instruments=[]
	self.save!
	self.destroy
  end

  def upgrade_account(editor_flag)
	# legacy accounts
	if (self.password)
	  self.authenticate(self.username, self.password)
	end
	self.editor_flag=editor_flag.to_i
	self.save!
  end

  # JSON filtering
  def as_json(options={})
	options[:except] ||= [:password, :salt, :crypted_password]
	super(options)
  end



  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
	u = find_by_username(login) # need to get the salt
	u && u.authenticated?(password) ? u : nil
  end

  def authenticated?(inpwd)
	false
	if (!salt && password==inpwd)
	  save
	  true
	elsif (encrypt(inpwd)==crypted_password)
	  true
	end
  end

  def remember_token?
	remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
	self.remember_token_expires_at = 2.weeks.from_now.utc
	self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
	save()
  end

  def forget_me
	self.remember_token_expires_at = nil
	self.remember_token            = nil
	save()
  end


  private


  # Encrypts some data with the salt. Class method
  def self.encrypt(password, salt)
	Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
	self.class.encrypt(password, salt)
  end

  def reprocess_avatar
	avatar.reprocess!
  end


  # before filter
  def encrypt_password
	return if password.blank?

	self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{username}--") if new_record?
	self.crypted_password = encrypt(password)
	if (self.password)
	  self.password=nil
	end
	self.modified_date=Time.now.to_s
  end

  def password_required?
	crypted_password.blank? || !password.blank?
	false
  end


end
