
class UserService

  @@otp = nil

  def self.register_user(user_params)
    user = User.new(user_params)
    if user.save
      user
    else
      nil
    end
  end

  def self.login_user(email, password)
    user = User.find_by(email: email)
    raise StandardError , "Invalid email" if user.nil?
    raise StandardError, "Invalid password" unless user&.authenticate(password)
    user
  end

  def self.forgetPassword(forget_password_params)
    user = User.find_by(email: forget_password_params[:email])
    if user 
      @@otp = rand(100000..999999)
      return {success: true , otp: @@otp}
    else
      return {success: false}
    end
  end

  def self.resetPassword(user_id, reset_password_params)
    if reset_password_params[:otp].to_i != @@otp
      return { success: false, message: "Invalid OTP" }
    end
  
    user = User.find_by(id: user_id)
    if user
      user.update(password: reset_password_params[:new_password])
      @@otp = nil
      return { success: true, message: "Password successfully reset" }
    else
      return { success: false, message: "User not found" }
    end
  end

end
