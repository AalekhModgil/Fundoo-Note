class Api::V1::NotesController < ApplicationController
  skip_before_action :verify_authenticity_token
  def createNote
    token = request.headers["Authorization"]&.split(" ")&.last
    result = NoteService.create_note(note_params, token)
    if result[:success]
      render json: { message: result[:message] }, status: :ok # rubocop:disable Layout/SpaceInsideHashLiteralBraces
    else
      render json: { errors: result[:error] }, status: :unprocessable_entity
    end
  end


  private

  def note_params
    params.permit(:title, :content)
  end
end
