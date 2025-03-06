class NoteService
    def self.create_note(note_params, token)
     user_data = JsonWebToken.decode(token)
      unless user_data
        return { success: false, error: "Unauthorized access" }
      end
      note =user_data.notes.new(note_params)
      if note.save
        REDIS.del("user_#{user_data[:id]}_notes") # Clear cache
        { success: true, message: "Note added successfully", note: note }
      else
        { success: false, error: "Couldn't add note" }
      end
    end

    # def self.getNote(token)
    #   user_data = JsonWebToken.decode(token)
    #   unless user_data
    #     { success: false, error: "Unauthorized access" }
    #   end
    #   note = user_data.notes.where(is_deleted: false).includes(:user)
    #   if note
    #       # notes_with_user = user_data.notes.map do |note|
    #       #   {
    #       #     note: note,
    #       #     user: note.user  # Including the user associated with each note
    #       #   }
    #       # end
    #       { success: true, body: note }
    #   else
    #     { success: false, error: "Couldn't get notes" }
    #   end
    # end

    # def self.getNote(token)
    #     user_data = JsonWebToken.decode(token)
    #     unless user_data
    #       { success: false, error: "Unauthorized access" }
    #     end
    #     cache_key = "user_#{user_data[:id]}_notes"
    #     cached_notes = REDIS.get(cache_key)
    #     if cached_notes
    #       notes = JSON.parse(cached_notes)
    #     else
    #       notes = user_data.notes.where(is_deleted: false).includes(:user).as_json
    #       REDIS.set(cache_key, notes.to_json)
    #       REDIS.expire(cache_key, 300)
    #     end
    #     { success: true, body: notes }
    # end

    def self.getNote(token)
      user_data = JsonWebToken.decode(token)
      return { success: false, error: "Unauthorized access" } unless user_data

      cache_key = "user_#{user_data[:id]}_notes"
      cached_notes = REDIS.get(cache_key)

      if cached_notes
        notes = JSON.parse(cached_notes)
      else
        notes = Note.where(user_id: user_data[:id]) # Fetch all notes for the user
                    .includes(:user)
                    .as_json
        REDIS.set(cache_key, notes.to_json)
        REDIS.expire(cache_key, 300)
      end

      { success: true, body: notes }
    end


    def self.get_note_by_id(note_id, token)
      user_data = JsonWebToken.decode(token)
      return { success: false, error: "Unauthorized access" } if user_data.nil?

      note = Note.find_by(id: note_id)
      return { success: false, error: "Note not found" } if note.nil?

      if user_data[:id] == note.user_id
        { success: true, note: note }
      else
        { success: false, error: "Token not valid for this note" }
      end
    end

    # def self.trash_toggle(note_id)
    #   note = Note.find_by(id: note_id)
    #   if note
    #      if note.is_deleted == false
    #         note.update(is_deleted: true)
    #      else
    #         note.update(is_deleted: false)
    #      end
    #      REDIS.del("user_#{note.user_id}_notes")
    #      { success: true, message: "Status toggled" }
    #   else
    #      { success: false, errors: "Couldn't toggle the status" }
    #   end
    # end

    def self.trash_toggle(note_id)
      note = Note.find_by(id: note_id)
      return { success: false, errors: "Note not found" } unless note

      note.update(is_deleted: !note.is_deleted)
      REDIS.del("user_#{note.user_id}_notes") # Clear cache

      { success: true, message: "Trash status toggled", note: note }
    end


    def self.archive_toggle(note_id)
      note = Note.find_by(id: note_id)
      if note
        if note.is_archived == false
          note.update(is_archived: true)
        else
          note.update(is_archived: false)
        end
        REDIS.del("user_#{note.user_id}_notes")
         { success: true, message: "Archive status toggled" }
      else
         { success: false, errors: "Couldn't toggle the archive status" }
      end
    end

    def self.update_colour(note_id, colour)
      note = Note.find_by(id: note_id)
      if note
        old_colour = note.colour
        note.update(colour: colour)
        REDIS.del("user_#{note.user_id}_notes")
        { success: true, message: "Colour changed from #{old_colour} to #{colour} successfully" }
      else
        { success: false, errors: "Unable to change colour" }
      end
    end

    def self.update_note(note_id, note_params, token)
      user_data = JsonWebToken.decode(token)
      return { success: false, error: "Unauthorized access" } unless user_data

      note = Note.find_by(id: note_id)
      return { success: false, error: "Note not found" } unless note

      # Verify the note belongs to the authenticated user
      return { success: false, error: "Unauthorized to update this note" } unless user_data[:id] == note.user_id

      if note.update(note_params)
        REDIS.del("user_#{note.user_id}_notes") # Clear cache
        { success: true, message: "Note updated successfully", note: note }
      else
        { success: false, error: note.errors.full_messages.join(", ") }
      end
    end

    def self.delete_note(note_id)
      note = Note.find_by(id: note_id)
      return { success: false, errors: "Note not found" } unless note

      note.destroy
      REDIS.del("user_#{note.user_id}_notes") # Clear cache to update frontend

      { success: true, message: "Note deleted permanently" }
    end
end
