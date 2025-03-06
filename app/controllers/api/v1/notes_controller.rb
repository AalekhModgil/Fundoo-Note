class Api::V1::NotesController < ApplicationController
  skip_before_action :verify_authenticity_token
  def createNote
    token = request.headers["Authorization"]&.split(" ")&.last
    result = NoteService.create_note(note_params, token)
    if result[:success]
      render json: { message: result[:message], note: result[:note] }, status: :ok
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

  def archiveToggle
    note_id = params[:id]
    result = NoteService.archive_toggle(note_id)
    if result[:success]
      render json: { message: result[:message] }, status: :ok
    else
      render json: { errors: result[:errors] }, status: :bad_request
    end
  end

  def updateColour
    note_id = params[:id]
    colour = params[:colour]
    result = NoteService.update_colour(note_id, colour)
    if result[:success]
      render json: { message: result[:message] }, status: :ok
    else
      render json: { errors: result[:errors] }, status: :bad_request
    end
  end

  def updateNote
    token = request.headers["Authorization"]&.split(" ")&.last
    note_id = params[:id]
    result = NoteService.update_note(note_id, note_params, token)

    if result[:success]
      render json: { message: result[:message], note: result[:note] }, status: :ok
    else
      render json: { errors: result[:error] }, status: :unprocessable_entity
    end
  end

  def deleteNote
    note_id = params[:id]
    result = NoteService.delete_note(note_id)

    if result[:success]
      render json: { message: result[:message] }, status: :ok
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  private

  def note_params
    params.permit(:title, :content)
  end
end
