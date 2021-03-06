class Notifier < ActionMailer::Base
  default :from =>   'notification@jazzhouston.com'

  def confirmation_email(user, subject, key)

    @username =  user.username
    @key = key
    mail(:to => user.email, :subject => subject)

  end

  def signup_notification(user, subject)
    @account = user
    mail(:to => user.email, :subject => subject)

  end

  def lost_password(user, subject, key)

    @account = user
    @key = key
    mail(:to => user.email, :subject => subject)
  end

  def updated_password(user, subject)
    @account = user
    mail(:to => user.email, :subject => subject)
  end


  def feedback(to, name, email, subject, message)
    @message = message
    @sender_name = name
    @sender_email = email
    mail(:to => to, :reply_to => email || to, :subject => subject)
  end



end
