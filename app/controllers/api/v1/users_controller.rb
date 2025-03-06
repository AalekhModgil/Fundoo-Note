
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
        if params[:email].blank? || params[:password].blank?
          render json: { status: "error", message: "Missing email or password" }, status: :bad_request
          return
        end

        user = User.find_by(email: params[:email])
        if user && user.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: user.id, name: user.name, email: user.email)
          render json: { message: "Login successful", token: token,  user: { name: user.name, email: user.email }  }, status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      # def forgetPassword
      #   response = UserService.forgetPassword(forget_password_params)
      #   if response[:success]
      #     render json: { email: forget_password_params[:email], message: response[:message], otp: response[:otp] }, status: :ok
      #   else
      #     render json: { errors: "Email not registered" }, status: :not_found
      #   end
      # end
      def forgetPassword
        response = UserService.forgetPassword(forget_password_params)
        if response[:success]
          user = User.find_by(email: forget_password_params[:email])
          render json: {
            email: forget_password_params[:email],
            message: response[:message],
            otp: response[:otp],
            user_id: user.id
          }, status: :ok
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
