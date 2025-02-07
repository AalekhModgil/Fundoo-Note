class UserMailer < ApplicationMailer
  default from: "aalekhmodgil8@gmail.com"

  def self.enqueue_otp_email(user, otp)
    channel = RabbitMQ.create_channel
    queue = channel.queue("otp_emails")
    
    message = { email: user.email, otp: otp }.to_json
    queue.publish(message, persistent: true)
  end

  # method for sending OTP email
 
  def otp_email(user, otp)
    @user = user
    @otp = otp
    mail(to: @user.email, subject: "Your OTP for Password reset")
  end

  # method for send password reset success email

  def password_reset_success_email(user)
    @user = user
    mail(to: @user.email, subject: "Your password has been successfully reset")
  end
end
