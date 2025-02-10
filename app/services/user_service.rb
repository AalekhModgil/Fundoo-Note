
class UserService
  def self.register_user(user_params)
    user = User.new(user_params)
    if user.save
      { success: true }
    else
      { success: false }
    end
  end

  def self.login_user(email, password)
    user = User.find_by(email: email)
    raise StandardError, "Invalid email" if user.nil?
    raise StandardError, "Invalid password" unless user&.authenticate(password)
    user
  end

  def self.forgetPassword(forget_password_params)
    user = User.find_by(email: forget_password_params[:email])
    if user
      @@otp = rand(100000..999999)
      @@otp_generated_at = Time.current
      # UserMailer.otp_email(user, @@otp).deliver_now # Send OTP email
      UserMailer.enqueue_otp_email(user, @@otp) # Send to RabbitMQ
      # EmailWorker.start
      Thread.new { EmailWorker.start }  # rails runner EmailWorker.start in terminal
      { success: true, otp: @@otp }
    else
      { success: false }
    end
  end

  def self.resetPassword(user_id, reset_password_params)
    if reset_password_params[:otp].to_i != @@otp || (Time.current - @@otp_generated_at > 1.minute)
      { success: false, message: "Invalid OTP" }
    end
    user = User.find_by(id: user_id)
    if user
      user.update(password: reset_password_params[:new_password])
      @@otp = nil
      UserMailer.password_reset_success_email(user).deliver_now # Send password reset success email
      { success: true, message: "Password successfully reset" }
    else
      { success: false, message: "User not found" }
    end
  end

  private
  @@otp = nil
  @@otp_generated_at = nil
end

# User requests password reset → UserService generates OTP
# UserService sends OTP message to the RabbitMQ queue
# EmailWorker listens to the queue, picks up the OTP message
# EmailWorker sends OTP email to the user
