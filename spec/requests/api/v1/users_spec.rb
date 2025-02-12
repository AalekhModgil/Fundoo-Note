require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  # Register User API
  path '/api/v1/users' do
    post 'Register a new user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      # Parameters wrapped in 'user'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          password: { type: :string },
          phone_number: { type: :string, example: "+919876543210" }
        },
        required: [ 'name', 'email', 'password', 'phone_number' ]
      }

      response '201', 'User registered successfully' do
        let(:user) { { name: 'Person10', email: 'person10@gmail.com', password: 'Person10@1234', phone_number: '+919876543217' } }
        run_test!
      end

      response '422', 'Invalid request' do
        let(:user) { { email: 'invalid-email' } }
        run_test!
      end
    end
  end

  # User Login API
  path '/api/v1/users/login' do
    post 'Login a user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: "person8@gmail.com" },
          password: { type: :string, example: "Person8@1234" }
        },
        required: [ 'email', 'password' ]
      }

      response '200', 'Login successful' do
        let(:user) { { email: 'person8@gmail.com', password: 'Person8@1234' } }
        run_test!
      end

      response '400', 'Invalid password' do
        let(:user) { { email: 'person8@gmail.com', password: 'wrongpassword' } }
        run_test!
      end
    end
  end

# Forgot Password API
path '/api/v1/users/forget' do
  put 'Forgot Password' do
    tags 'Users'
    consumes 'application/json'
    produces 'application/json'

    parameter name: :request_body, in: :body, schema: {
      type: :object,
      properties: {
        email: { type: :string, example: "asharma980511@gmail.com" }
      },
      required: [ 'email' ]
    }

    response '200', 'OTP sent successfully' do
      let(:request_body) { { email: 'asharma980511@gmail.com' } }
      run_test!
    end

    response '404', 'User not found' do
      let(:request_body) { { email: 'nonexistent@example.com' } }
      run_test!
    end
  end
end

# Reset Password API
path '/api/v1/users/reset/{id}' do
  put 'Reset Password' do
    tags 'Users'
    consumes 'application/json'
    produces 'application/json'

    parameter name: :id, in: :path, type: :integer, description: 'User ID'
    parameter name: :reset_data, in: :body, schema: {
      type: :object,
      properties: {
        otp: { type: :string, example: "786344" },
        new_password: { type: :string, example: "AmanSharma@123" }
      },
      required: [ 'otp', 'new_password' ]
    }

    response '200', 'Password reset successfully' do
      let(:id) { 1 }
      let(:reset_data) { { otp: '786344', new_password: 'AmanSharma@123' } }
      run_test!
    end

    response '422', 'Invalid OTP or User not found' do
      let(:id) { 1 }
      let(:reset_data) { { otp: '000000', new_password: 'AmanSharma@123' } }
      run_test!
    end
  end
end
end
