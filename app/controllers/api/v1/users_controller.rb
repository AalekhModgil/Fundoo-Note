  module Api
    module V1

  class UsersController < ApplicationController
    skip_before_action :verify_authenticity_token

    def showAllUsers
      users = User.all
      render json: users, status: :ok
    end


    def showUserById
      user = User.find(params[:id])
      render json: user, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: {error: "User not found"}, status: :not_found
    end


    def userRegistration
      user = User.new(user_params)

      if user.save
        render json: user, status: :created
      else
        render json: { errors: user.errors }, status: :unprocessable_entity
      end
    end

    def deleteUserById
      user = User.find(params[:id])
      user.destroy
      render json: {message: "User deleted succcessfully"}, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: {error: "User not found"}, status: :not_found
    end

    private

    def user_params
      params.permit(:name, :email, :password , :phone_number)
    end
  end

  end
  end