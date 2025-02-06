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

  def getNote
    token = request.headers["Authorization"]&.split(" ")&.last
    result = NoteService.getNote(token)
    if result[:success]
      render json: result[:body], status: :ok
    else
      render json: { errors: result[:error] }, status: :unprocessable_entity
    end
  end

  def getNoteById
    token = request.headers["Authorization"]&.split(" ")&.last
    note_id = params[:id]
    result = NoteService.get_note_by_id(note_id, token)
    if result[:success]
      render json: result[:note], status: :ok
    else
      render json: { errors: result[:error] }, status: :unprocessable_entity
    end
  end

  def trashToggle
    note_id = params[:id]
    result = NoteService.trash_toggle(note_id)
    if result[:success]
      render json: { message: result[:message] }, status: :ok
    else
      render json: { errors: result[:errors] }, status: :bad_request
    end
  end

  private

  def note_params
    params.permit(:title, :content)
  end
end
