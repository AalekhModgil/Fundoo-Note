
class Api::V1::UsersController < ApplicationController
      before_action :authorize_request, except: [:userLogin, :userRegistration]

      def showAllUsers
        users = UserService.show_all_users
        render json: users, status: :ok
      end

      def showUserById
        user = UserService.show_user_by_id(params[:id])
        if user
          render json: user, status: :ok
        else
          render json: { error: "User not found" }, status: :not_found
        end
      end

      def userRegistration
        user = UserService.register_user(user_params)
        if user
          render json: user, status: :created
        else
          render json: { errors: user.errors }, status: :unprocessable_entity
        end
      end

      def deleteUserById
        user = UserService.delete_user_by_id(params[:id])
        if user
          render json: { message: "User deleted successfully" }, status: :ok
        else
          render json: { error: "User not found" }, status: :not_found
        end
      end

      def userLogin
        user = UserService.login_user(params[:email], params[:password])
        if user
          token = JsonWebToken.encode(user_id: user.id, name: user.name, email: user.email)
          render json: { status: 'success', token: token, message: 'Login successful' , status: :ok }, status: :ok
        else
          render json: { status: 'error', error: 'Invalid email or password' , status: :unauthorized }, status: :unauthorized
        end
      end

      private

      def user_params
        params.permit(:name, :email, :password, :phone_number)
      end
end

