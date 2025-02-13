require 'rails_helper'

RSpec.describe UserService, type: :service do
  let(:user) { User.create!(name: "Aryan", email: "aryan7@gmail.com", phone_number: "+917867712040", password: "Aryan7@123") }

  describe ".register_user" do
    context "when valid user params are provided" do
      it "creates a new user and returns success" do
        user_params = { name: "Aalekh", email: "aalekhmodgil8@gmail.com", phone_number: "+917867712040", password: "Aalekh8@123" }
        result = UserService.register_user(user_params)

        expect(result[:success]).to eq(true)
        expect(User.find_by(email: "aalekhmodgil8@gmail.com")).to be_present
      end
    end

    context "when invalid user params are provided" do
      it "fails to create a user and returns an error for missing email" do
        user_params = { email: "", password: "ValidPassword123" }
        result = UserService.register_user(user_params)

        expect(result[:success]).to eq(false)
        expect(result[:errors]).to include("Email can't be blank")
      end

      it "fails to create a user and returns an error for missing password" do
        user_params = { email: "test@example.com", password: "" }
        result = UserService.register_user(user_params)

        expect(result[:success]).to eq(false)
        expect(result[:errors]).to include("Password can't be blank")
      end

      it "fails to create a user and returns an error for invalid email format" do
        user_params = { email: "invalid-email", password: "ValidPassword123" }
        result = UserService.register_user(user_params)

        expect(result[:success]).to eq(false)
        expect(result[:errors]).to include("Email must be a valid email format")
      end

      it "fails to create a user and returns an error for password too short" do
        user_params = { email: "test@example.com", name: "Valid Name", phone_number: "+1234567890", password: "short" }
        result = UserService.register_user(user_params)

        expect(result[:success]).to eq(false)
        expect(result[:errors]).to include("Password must be atleast 8 characters long , include one lowercase letter , one uppercase letter , one digit, and one special character")
      end

      it "fails to create a user and returns an error for non-matching password confirmation" do
        user_params = { email: "test@example.com", password: "ValidPassword123", password_confirmation: "MismatchedPassword" }
        result = UserService.register_user(user_params)

        expect(result[:success]).to eq(false)
        expect(result[:errors]).to include("Password confirmation doesn't match Password")
      end
    end
  end

  describe ".login_user" do
    context "when credentials are valid" do
      it "returns the user" do
        expect(UserService.login_user(user.email, user.password)).to eq(user)
      end
    end

    context "when email is invalid" do
      it "raises an error" do
        expect { UserService.login_user("wrong@example.com", "Valid@123") }.to raise_error(StandardError, "Invalid email")
      end
    end

    context "when password is incorrect" do
      it "raises an error" do
        expect { UserService.login_user(user.email, "WrongPass") }.to raise_error(StandardError, "Invalid password")
      end
    end
  end

  describe "#forgetPassword" do
    context "when the email exists" do
      it "sends an OTP to the email" do
        User.create!(name: "John Doe", email: "john@example.com", password: "Password123@", phone_number: "+8907653241")
        forget_password_params = { email: "john@example.com" }

        result = UserService.forgetPassword(forget_password_params)

        expect(result[:success]).to be(true)
        expect(result[:message]).to eq("OTP has been sent to john@example.com, check your inbox")
        expect(result[:otp]).to be_present
        expect(result[:otp_generated_at]).to be_present
      end
    end

    context "when the email does not exist" do
      it "returns failure" do
        forget_password_params = { email: "nonexistent@example.com" }

        result = UserService.forgetPassword(forget_password_params)

        expect(result[:success]).to be(false)
      end
    end
  end

  describe "#resetPassword" do
    context "when OTP is valid" do
      it "resets the user's password" do
        user = User.create!(name: "John Doe", email: "john@example.com", password: "Password123@", phone_number: "+8907653241")

        forget_password_params = { email: "john@example.com" }
        result_forget = UserService.forgetPassword(forget_password_params)

        expect(result_forget[:otp]).to be_present

        reset_password_params = { otp: result_forget[:otp], new_password: "NewPassword123@" }

        result = UserService.resetPassword(user.id, reset_password_params)

        expect(result[:success]).to be(true)

        user.reload
        expect(user.authenticate("NewPassword123@")).to be_truthy
      end
    end

    context "when OTP is invalid" do
      it "returns failure" do
        user = User.create!(name: "John Doe", email: "john@example.com", password: "Password123@", phone_number: "+8907653241")

        forget_password_params = { email: "john@example.com" }
        result_forget = UserService.forgetPassword(forget_password_params)

        expect(result_forget[:otp]).to be_present

        reset_password_params = { otp: "wrongotp", new_password: "NewPassword123@" }

        result = UserService.resetPassword(user.id, reset_password_params)

        expect(result[:success]).to be(false)
        expect(result[:message]).to eq("Invalid OTP")
      end
    end

    context "when OTP expires" do
      it "returns failure" do
        user = User.create!(name: "John Doe", email: "john@example.com", password: "Password123@", phone_number: "+8907653241")

        reset_password_params = { otp: "expiredotp", new_password: "NewPassword123@" }

        result = UserService.resetPassword(user.id, reset_password_params)

        expect(result[:success]).to be(false)
        expect(result[:message]).to eq("Invalid OTP")
      end
    end

    context "when the user does not exist" do
      it "returns failure with a user not found message" do
        forget_password_params = { email: "nonexistent@example.com" }
        result_forget = UserService.forgetPassword(forget_password_params)

        reset_password_params = { otp: result_forget[:otp], new_password: "NewPassword123@" }

        result = UserService.resetPassword(9999, reset_password_params)

        expect(result[:success]).to be(false)
        expect(result[:message]).to eq("User not found")
      end
    end
  end
end
