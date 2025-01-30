class UserMailer < ApplicationMailer
  default from: 'aalekhmodgil8@gmail.com'

  # method for sending OTP email

  def otp_email(user,otp)
    @user = user
    @otp = otp
    mail(to:@user.email , subject: 'Your OTP for Password reset')
  end

  # method for send password reset success email

  def password_reset_success_email(user)
    @user = user
    mail(to:@user.email, subject: 'Your password has been successfully reset')
  end

end
