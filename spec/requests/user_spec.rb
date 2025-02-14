require 'rails_helper'

RSpec.describe "User Authentication", type: :request do
  describe "POST /api/v1/users" do
    it "registers a new user successfully" do
      post "/api/v1/users", params: {
        name: "Test User",
        email: "test@example.com",
        phone_number: "+1234567890",
        password: "Strong@123"
      }
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["message"]).to eq("User created successfully")
    end

    it "fails to register with invalid email" do
      post "/api/v1/users", params: {
        name: "Test User",
        email: "invalid-email",
        phone_number: "+1234567890",
        password: "Strong@123"
      }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "POST /api/v1/users/login" do
    before do
      User.create!(name: "Test User", email: "test@example.com", phone_number: "+1234567890", password: "Strong@123")
    end
    context "with valid credentials" do
      it "logs in and returns a token" do
        post "/api/v1/users/login", params: { email: "test@example.com", password: "Strong@123" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Login successful")
        expect(JSON.parse(response.body)["token"]).not_to be_nil
      end
    end

    context "with invalid email" do
      it "returns an error message" do
        post "/api/v1/users/login", params: { email: "invalid@example.com", password: "Strong@123" }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Invalid email or password")
      end
    end

    context "with invalid password" do
      it "returns an error message" do
        post "/api/v1/users/login", params: { email: "test@example.com", password: "WrongPassword" }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Invalid email or password")
      end
    end

    context "with missing parameters" do
      it "returns an error when email is missing" do
        post "/api/v1/users/login", params: { password: "Strong@123" }
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["status"]).to eq("error")
        expect(JSON.parse(response.body)["message"]).to eq("Missing email or password")
      end

      it "returns an error when password is missing" do
        post "/api/v1/users/login", params: { email: "test@example.com" }
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["status"]).to eq("error")
        expect(JSON.parse(response.body)["message"]).to eq("Missing email or password")
      end
    end
  end
end
