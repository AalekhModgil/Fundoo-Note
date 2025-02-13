require 'rails_helper'

RSpec.describe NoteService, type: :service do
  let(:user) { User.create!(name: "Aryan", email: "aryan7@gmail.com", phone_number: "+917867712040", password: "Aryan7@123") }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let!(:note) { user.notes.create!(title: "Test Note", content: "This is a test note.") }
  let(:invalid_token) { "invalidtoken" }

  describe ".create_note" do
    context "when valid note params and token are provided" do
      it "creates a new note and returns success" do
        note_params = { title: "New Note", content: "This is a test note." }
        result = NoteService.create_note(note_params, token)

        expect(result[:success]).to eq(true)
        expect(result[:message]).to eq("Note added successfully")
        expect(user.notes.find_by(title: "New Note")).to be_present
      end
    end

    context "when token is missing or invalid" do
      it "returns an unauthorized error" do
        note_params = { title: "Invalid Note", content: "No token provided." }
        result = NoteService.create_note(note_params, nil)

        expect(result[:success]).to eq(false)
        expect(result[:error]).to eq("Unauthorized access")
      end
    end

    context "when note creation fails" do
      it "returns an error message" do
        allow_any_instance_of(Note).to receive(:save).and_return(false)
        note_params = { title: "Failing Note", content: "This should fail." }
        result = NoteService.create_note(note_params, token)

        expect(result[:success]).to eq(false)
        expect(result[:error]).to eq("Couldn't add note")
      end
    end
  end

  describe ".getNote" do
    context "when token is valid" do
      it "returns the user's notes" do
        result = NoteService.getNote(token)

        expect(result[:success]).to eq(true)
        expect(result[:body]).to be_an(Array)
        expect(result[:body].first["title"]).to eq("Test Note")
      end
    end

    context "when token is missing or invalid" do
      it "returns an unauthorized error" do
        note_params = { title: "Invalid Note", content: "No token provided." }
        result = NoteService.create_note(note_params, nil)  # Using nil token

        expect(result[:success]).to eq(false)
        expect(result[:error]).to eq("Unauthorized access")
      end
    end

    context "when notes are cached" do
      it "fetches notes from cache instead of database" do
        cache_key = "user_#{user.id}_notes"
        cached_notes = [ { "title" => "Cached Note", "content" => "Cached content" } ].to_json
        REDIS.set(cache_key, cached_notes)

        result = NoteService.getNote(token)

        expect(result[:success]).to eq(true)
        expect(result[:body].first["title"]).to eq("Cached Note")
      end
    end

    context "when user has no notes" do
      it "returns an empty array" do
        user.notes.destroy_all
        result = NoteService.getNote(token)

        expect(result[:success]).to eq(true)
        expect(result[:body]).to eq([])
      end
    end
  end


  describe ".get_note_by_id" do
    context "when token is valid and note exists" do
      it "returns the note" do
        result = NoteService.get_note_by_id(note.id, token)

        expect(result[:success]).to eq(true)
        expect(result[:note].title).to eq("Test Note")
      end
    end

    context "when token is valid but note does not exist" do
      it "returns note not found error" do
        result = NoteService.get_note_by_id(99999, token) # Non-existent note

        expect(result[:success]).to eq(false)
        expect(result[:error]).to eq("Note not found")
      end
    end

    context "when token is invalid" do
      it "returns unauthorized access error" do
        result = NoteService.get_note_by_id(note.id, invalid_token)

        expect(result[:success]).to eq(false)
        expect(result[:error]).to eq("Unauthorized access")
      end
    end

    context "when token does not match note user" do
      let(:other_user) { User.create!(name: "Sham", email: "sham@gmail.com", phone_number: "+917867712045", password: "Sham123@") }
      let(:other_user_token) { JsonWebToken.encode(user_id: other_user.id) }

      it "returns token not valid for this note" do
        result = NoteService.get_note_by_id(note.id, other_user_token)

        expect(result[:success]).to eq(false)
        expect(result[:error]).to eq("Token not valid for this note")
      end
    end
  end

  describe ".trash_toggle" do
    context "when note exists" do
      it "toggles the trash status of the note" do
        result = NoteService.trash_toggle(note.id)

        expect(result[:success]).to eq(true)
        expect(result[:message]).to eq("Status toggled")
        expect(note.reload.is_deleted).to eq(true)
      end
    end

    context "when note does not exist" do
      it "returns an error message" do
        result = NoteService.trash_toggle(99999) # Non-existent note

        expect(result[:success]).to eq(false)
        expect(result[:errors]).to eq("Couldn't toggle the status")
      end
    end
  end

  describe ".archive_toggle" do
    context "when note exists" do
      it "toggles the archive status of the note" do
        result = NoteService.archive_toggle(note.id)

        expect(result[:success]).to eq(true)
        expect(result[:message]).to eq("Archive status toggled")
        expect(note.reload.is_archived).to eq(true)
      end
    end

    context "when note does not exist" do
      it "returns an error message" do
        result = NoteService.archive_toggle(99999) # Non-existent note

        expect(result[:success]).to eq(false)
        expect(result[:errors]).to eq("Couldn't toggle the archive status")
      end
    end
  end

  describe ".update_colour" do
    context "when note exists" do
      it "updates the note's colour" do
        previous_colour = note.colour
        result = NoteService.update_colour(note.id, "blue")

        expect(result[:success]).to eq(true)
        expect(result[:message]).to eq("Colour changed from #{previous_colour} to blue successfully")
        expect(note.reload.colour).to eq("blue")
      end
    end

    context "when note does not exist" do
      it "returns an error message" do
        result = NoteService.update_colour(99999, "blue") # Non-existent note

        expect(result[:success]).to eq(false)
        expect(result[:errors]).to eq("Unable to change colour")
      end
    end
  end
end
