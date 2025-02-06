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


end
