#
# The User class
# password is encrypted by algorithms within

# Now supporting two legacy login systems, one circa 2000 was plain-text password (!)
#   the other circa 2008 was SHA1-based.
# Devise is the new standard (2014)
#
class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  set_primary_key "user_id"
  set_table_name "users"
  has_many :musician_instruments, :dependent => :destroy
  has_many :instruments, :through => :musician_instruments
  has_many :posts
  has_many :user_bans

  # white-listed. Note :password is the user-entered password that is immediately changed on create
  # the real password is crypted_password, which is most definitely not white-listed
  attr_accessible :username, :email, :password, :password_confirmation,  :first_name, :last_name, :about_me,
                  :occupation, :location, :url, :favorite_music, :favorite_films, :home_phone,
                  :cell_phone, :image, :image_url, :hide_email, :twitter_name, :remember_me, :legacy_password_field


  validates_presence_of     :username, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :username, :within => 2..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :username, :case_sensitive => false

  ## CarrierWave gem
  mount_uploader :image, ImageUploader


  #========================
  # Public Model Functions
  #========================

  # JSON filtering
  def as_json(options={})
    options[:except] ||= [:password, :salt, :crypted_password]
    super(options)
  end

  # DB Search class method (to be replaced by a proper search engine someday)
  def self.search_users(search_term)
    User
    .where("lower(username) like ? or lower(first_name) like ? or lower(last_name) like ? ", search_term, search_term, search_term)
    .order("last_name")
    .select("username, first_name, last_name, user_id")
  end

  # change password
  def change_password(username, old_password, new_password)
    u = User.authenticate(username, old_password)
    if u
      u.password = new_password
      u.save(:validate => false)
      true
    else
      false
    end
  end


  # simple delete account
  def delete_account
    self.instruments=[]
    self.save!
    self.destroy
  end

  # update password
  def update_password(new_password)
    self.password = new_password
    self.save!
  end

  # upgrade account to editor
  def upgrade(editor_flag)
    # legacy accounts
    if self.password
      self.authenticate(self.username, self.password)
    end
    self.editor_flag=editor_flag.to_i
    self.save!
  end


  #==========================
  # Authentication Functions
  #==========================

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_username(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end


  ## Override Devise's password validation to handle legacy logins
  def valid_password?(password)
    # if legacy auth, update, and continue
    if self.encrypted_password.blank?
      logger.debug "Running the LEGACY password validation test on #{self.username}"
      return false unless authenticated?(password)
    end
    super
  end

  protected


  # legacy authentication with reset
  def authenticated?(inpwd)
    # try legacy accounts
    if (salt.nil? && self.legacy_password_field == inpwd) || (encrypt(inpwd) == crypted_password )
      update_legacy_fields(inpwd)
      return true
    end
    false
  end


  # Legacy update on passwords
  def update_legacy_fields(password)
    logger.debug "have passed legacy, now we're updating passwords"
    self.crypted_password = nil unless self.crypted_password.nil?
    self.legacy_password_field = nil unless self.legacy_password_field.nil?
    self.password = password
    self.skip_confirmation!
    self.save(:validate => false)
  end

  def password_required?
    encrypted_password.blank? || (crypted_password.blank? && !legacy_password_field.blank?)
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


end
