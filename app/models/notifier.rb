class Notifier < ActionMailer::Base

    def confirmation_email(user, subject, key, sent_at = Time.now)
        recipients user.email
        from       'notification@jazzhouston.org'
        subject    subject
        sent_on    sent_at
        body       :username => user.username, :key=>key

    end


    def signup_notification(user, subject, sent_at = Time.now)
        recipients user.email
        from       'notification@jazzhouston.org'
        subject    subject
        sent_on    sent_at
        body       :account => user

    end

    def lost_password(user, subject, key, sent_at = Time.now)
        recipients user.email
        from       'notification@jazzhouston.org'
        subject    subject
        sent_on    sent_at
        body       :account => user,  :key=>key
    end

    def updated_password(user, subject, sent_at = Time.now)
        recipients user.email
        from       'notification@jazzhouston.org'
        subject    subject
        sent_on    sent_at
        body       :account => user
    end


    def feedback(to, name, email, subject, message, sent_at = Time.now)
        recipients to
        reply_to email
        from       'notification@jazzhouston.org'
        subject    subject
        sent_on    sent_at
        body       :from_addr => email, :from_name=>name, :message=>message
    end



end
