require "jwt"

class JsonWebToken
  SECRET_KEY = ENV['JWT_SECRET']

  def self.encode(payload)
    JWT.encode(payload, SECRET_KEY,'HS256')
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, algorithms: "HS256")[0]
    payload = HashWithIndifferentAccess.new(decoded)
    return User.find_by(id: payload[:user_id])
  rescue
    nil
  end
end
