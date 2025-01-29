# app/services/user_service.rb
class UserService
  def self.show_all_users
    User.all
  end

  def self.show_user_by_id(id)
    User.find(id)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def self.register_user(user_params)
    user = User.new(user_params)
    if user.save
      user
    else
      nil
    end
  end

  def self.delete_user_by_id(id)
    user = User.find(id)
    user.destroy
    user
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def self.login_user(email, password)
    user = User.find_by(email: email)
    return nil unless user && user.authenticate(password)

    user
  end
end
