

class User < ActiveRecord::Base

    # TODO replace file_column to carrierwave
    # http://www.engineyard.com/blog/2011/a-gentle-introduction-to-carrierwave/
    #
    #file_column :image, :magick => {
    #        :versions => {
    #                :thumb => {:crop => "1:1", :geometry => "50x50"},
    #                :profile => {:crop => "1:1", :geometry => "200x200"},
    #                :avatar => {:crop => "1:1", :geometry => "125x125"}
    #        }
    #}


    set_primary_key "user_id"
    set_table_name "users"
    has_many :musician_instruments, :dependent => :destroy
    has_many :instruments, :through => :musician_instruments
    has_many :messages
    has_many :user_bans

    # Virtual attribute for the unencrypted password
    #attr_accessor :password

    validates_presence_of     :username, :email
    validates_presence_of     :password,                   :if => :password_required?
    validates_presence_of     :password_confirmation,      :if => :password_required?
    validates_length_of       :password, :within => 4..40, :if => :password_required?
    validates_confirmation_of :password,                   :if => :password_required?
    validates_length_of       :username,    :within => 2..40
    validates_length_of       :email,    :within => 3..100
    validates_uniqueness_of   :username, :case_sensitive => false
    before_save :encrypt_password

    def as_json(options={})
	options[:except] ||= :password
  	super(options)
    end


    # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
    def self.authenticate(login, password)
        u = find_by_username(login) # need to get the salt
        u && u.authenticated?(password) ? u : nil
    end

    # Encrypts some data with the salt.
    def self.encrypt(password, salt)
        Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    end

    # Encrypts the password with the user salt
    def encrypt(password)
        self.class.encrypt(password, salt)
    end


    def authenticated?(inpwd)
        pass=false
        if (!salt &&(password==inpwd))
            puts "encrypting password, legacy mode"
            save(false)
            pass=true
        elsif (encrypt(inpwd)==crypted_password)
            pass=true
        end

        return pass
    end

    def remember_token?
        remember_token_expires_at && Time.now.utc < remember_token_expires_at
    end

    # These create and unset the fields required for remembering users between browser closes
    def remember_me
        self.remember_token_expires_at = 2.weeks.from_now.utc
        self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
        save(false)
    end

    def forget_me
        self.remember_token_expires_at = nil
        self.remember_token            = nil
        save(false)
    end

    protected

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
    end


end
