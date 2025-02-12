require "bunny"

# This worker continuously listens for messages in the queue and processes them (sends emails).
class EmailWorker
  def self.start
    channel = RabbitMQ.create_channel  # Get a channel
    queue = channel.queue("otp_emails")  # Connect to "otp_emails" queue

    puts " [*] Waiting for messages in otp_emails queue. To exit, press CTRL+C"

    queue.subscribe(block: true) do |_, _, body|
      message = JSON.parse(body) # Decode JSON message
      user = User.find_by(email: message["email"]) # Find user by email
      if user
        UserMailer.otp_email(user, message["otp"]).deliver_now # Send OTP email
        puts " [x] Sent OTP email to #{user.email}"
      end
    end
  end
end
