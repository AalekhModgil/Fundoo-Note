class UserMailer < ApplicationMailer
  default from: "aalekhmodgil8@gmail.com"

  # This method sends (publishes) the OTP message to RabbitMQ instead of immediately sending an email.
  def self.enqueue_otp_email(user, otp)
    channel = RabbitMQ.create_channel # Get a RabbitMQ channel
    queue = channel.queue("otp_emails")  # Declare a queue named "otp_emails"
    message = { email: user.email, otp: otp }.to_json # Convert OTP & email to JSON
    queue.publish(message, persistent: true) # Publish message to the exchange
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

# A Producer (Publisher) sends a message to an Exchange.
# The Exchange routes the message to one or more Queues based on its type.
# Consumers (Subscribers) listen to the Queues and process messages.
# Exchange is a middleman that routes messages to queues.
