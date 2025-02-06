class User < ApplicationRecord
  has_secure_password
  has_many :notes, dependent: :destroy

  validates :name, presence: true

  validates :phone_number, presence: true, uniqueness: true, format: { with: /\A\+?\d{10,15}\z/, message: "must be a valid phone number" }

  validates :email, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "must be a valid email format" }

  validates :password, presence: true, format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}\z/, message: "must be atleast 8 characters long , include one lowercase letter , one uppercase letter , one digit, and one special character" }
end
