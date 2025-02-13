require 'rails_helper'

RSpec.describe Note, type: :model do
  describe "associations" do
    it "belongs to a user" do
      user = User.create(name: "Aalekh", email: "aalekh@example.com", phone_number: "+911234567890", password: "Valid@123")
      note = user.notes.create(title: "Note 1", content: "Content 1")
      expect(note.user).to eq(user)
    end
  end

  describe "validations" do
    let(:user) { User.create(name: "Aalekh", email: "aalekh@example.com", phone_number: "+911234567890", password: "Valid@123") }
    let(:note) { user.notes.new(title: "Note 1", content: "Content 1") }

    it "is valid with valid attributes" do
      expect(note.valid?).to eq(true)
    end

    it "is invalid without a title" do
      note.title = nil
      expect(note.valid?).to eq(false)
      expect(note.errors[:title]).to include("can't be blank")
    end

    it "is invalid without content" do
      note.content = nil
      expect(note.valid?).to eq(false)
      expect(note.errors[:content]).to include("can't be blank")
    end
  end
end
