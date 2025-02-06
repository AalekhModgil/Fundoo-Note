class NoteService
    def self.create_note(note_params, token)
     user_data = JsonWebToken.decode(token)
      unless user_data
        return { success: false, error: "Unauthorized access" }, status: :unauthorized
      end
      note =user_data.notes.new(note_params)
      if note.save
        { success: true, message: "Note added successfully" }
      else
        { success: false, error: "Couldn't add note" }
      end
    end

    def self.getNote(token)
      user_data = JsonWebToken.decode(token)
      unless user_data
        { success: false, error: "Unauthorized access" }
      end
      note = user_data.notes.where(is_deleted: false).includes(:user)
      if note
          # notes_with_user = user_data.notes.map do |note|
          #   {
          #     note: note,
          #     user: note.user  # Including the user associated with each note
          #   }
          # end
          { success: true, body: note }
      else
        { success: false, error: "Couldn't get notes" }
      end
    end
end
