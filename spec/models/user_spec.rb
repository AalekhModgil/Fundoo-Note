require 'rails_helper'

RSpec.describe User, type: :model do
    describe "associations" do
      it "has many notes with dependent destroy" do
        user = User.create(name: "Aalekh", email: "aalekh@example.com", phone_number: "+911234567890", password: "Valid@123")
        note1 = user.notes.create(title: "Note 1", content: "Content 1")
        note2 = user.notes.create(title: "Note 2", content: "Content 2")

        expect(user.notes).to include(note1, note2)

        # Test dependent destroy
        user.destroy
        expect(Note.exists?(note1.id)).to eq(false)
        expect(Note.exists?(note2.id)).to eq(false)
      end
    end

  describe "validations" do
    let(:user) { User.new(name: "Aalekh", email: "aalekh@example.com", phone_number: "+911234567890", password: "Valid@123") }

    it "is valid with valid attributes" do
      expect(user.valid?).to eq(true)
    end

    it "is invalid without a name" do
      user.name = nil
      expect(user.valid?).to eq(false)
      expect(user.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a phone number" do
      user.phone_number = nil
      expect(user.valid?).to eq(false)
      expect(user.errors[:phone_number]).to include("can't be blank")
    end

    it "is invalid with a non-unique phone number" do
      User.create!(name: "Test", email: "test@example.com", phone_number: "+911234567890", password: "Valid@123")
      expect(user.valid?).to eq(false)
      expect(user.errors[:phone_number]).to include("has already been taken")
    end

    it "allows valid phone number format" do
      user.phone_number = "+919876543210"
      expect(user.valid?).to eq(true)
    end

    it "does not allow invalid phone number format" do
      user.phone_number = "123"
      expect(user.valid?).to eq(false)
      expect(user.errors[:phone_number]).to include("must be a valid phone number")
    end

    it "is invalid without an email" do
      user.email = nil
      expect(user.valid?).to eq(false)
      expect(user.errors[:email]).to include("must be a valid email format")
    end

    it "is invalid with a non-unique email" do
      User.create(name: "Test", email: "aalekh@example.com", phone_number: "+919999999999", password: "Valid@123")
      expect(user.valid?).to eq(false)
      expect(user.errors[:email]).to include("has already been taken")
    end

    it "allows valid email format" do
      user.email = "valid@example.com"
      expect(user.valid?).to eq(true)
    end

    it "does not allow invalid email format" do
      user.email = "invalid-email"
      expect(user.valid?).to eq(false)
      expect(user.errors[:email]).to include("must be a valid email format")
    end

    it "is invalid without a password" do
      user.password = nil
      expect(user.valid?).to eq(false)
      expect(user.errors[:password]).to include("can't be blank")
    end

    it "allows strong password" do
      user.password = "Strong@123"
      expect(user.valid?).to eq(true)
    end

    it "does not allow weak password" do
      user.password = "weakpass"
      expect(user.valid?).to eq(false)
      expect(user.errors[:password]).to include("must be atleast 8 characters long , include one lowercase letter , one uppercase letter , one digit, and one special character") # Adjust based on your validation message
    end
  end
end


# user.valid?
# returns true if the model passes all validations.
# returns false if any of the validations fail.

# User.create: Returns the object with errors if validation fails, does not raise an exception.
# User.create!: Raises an exception if validation fails, halting execution.
