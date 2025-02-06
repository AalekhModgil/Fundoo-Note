
class Api::V1::UsersController < ApplicationController
      skip_before_action :verify_authenticity_token
      rescue_from StandardError, with: :handle_login_error

      def userRegistration
        user = UserService.register_user(user_params)
        if user[:success]
          render json: user, status: :created
        else
          render json: { errors: user.errors }, status: :unprocessable_entity
        end
      end

      def userLogin
        user = UserService.login_user(params[:email], params[:password])
        if user
          token = JsonWebToken.encode(user_id: user.id, name: user.name, email: user.email)
          render json: { token: token, message: "Login successful", status: :ok }, status: :ok
        else
          render json: { error: "Invalid email or password", status: :unauthorized }, status: :unauthorized
        end
      rescue StandardError => e
        render json: { status: "error", message: e.message }, status: :bad_request
      end


      def forgetPassword
        response = UserService.forgetPassword(forget_password_params)
        if response[:success]
          render json: { email: forget_password_params[:email], otp: response[:otp] }, status: :ok
        else
          render json: { errors: "Email not registered" }, status: :not_found
        end
      end

      def resetPassword
        user_id = params[:id]
        response = UserService.resetPassword(user_id, reset_password_params)
        if response[:success]
          render json: { message: response[:message] }, status: :ok
        else
          render json: { message: response[:message] }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:name, :email, :password, :phone_number)
      end

      def forget_password_params
        params.permit(:email)
      end

      def reset_password_params
        params.permit(:new_password, :otp)
      end

      def handle_login_error(exception)
        if exception.message == "Invalid email"
          render json: { errors: "Invalid email" }, status: :bad_request
        else
          render json: { errors: "Invalid password" }, status: :bad_request
        end
      end
end
