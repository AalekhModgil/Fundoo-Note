require 'swagger_helper'

RSpec.describe 'Notes API', type: :request do
  path '/api/v1/notes/create' do
    post 'Create a new note' do
      tags 'Notes'
      consumes 'application/json'
      produces 'application/json'
      security [ BearerAuth: [] ]  # Requires JWT Authentication

      parameter name: :Authorization, in: :header, type: :string, description: 'Bearer Token', required: true

      parameter name: :note, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: 'New Note' },
          content: { type: :string, example: 'This is a new note' }
        },
        required: [ 'title', 'content' ]
      }

      response '200', 'Note created successfully' do
        let(:Authorization) { 'Bearer valid.jwt.token' }
        let(:note) { { title: 'New Note', content: 'This is a new note' } }
        run_test!
      end

      response '401', 'Unauthorized access' do
        let(:Authorization) { 'Bearer invalid.token' }
        let(:note) { { title: 'New Note', content: 'This is a new note' } }
        run_test!
      end

      response '422', 'Invalid request' do
        let(:Authorization) { 'Bearer valid.jwt.token' }
        let(:note) { { title: '' } } # Title is required
        run_test!
      end
    end
  end

  path '/api/v1/notes/getNote' do
    get 'Retrieve all notes for the authenticated user' do
      tags 'Notes'
      produces 'application/json'
      security [ BearerAuth: [] ]  # Requires JWT Authentication

      parameter name: :Authorization, in: :header, type: :string, description: 'Bearer Token', required: true

      response '200', 'Notes retrieved successfully' do
        let(:Authorization) { 'Bearer valid.jwt.token' }
        let(:user) { create(:user) }  # Assuming FactoryBot is used
        let!(:notes) { create_list(:note, 3, user: user, is_deleted: false) }

        before do
          allow(JsonWebToken).to receive(:decode).and_return({ id: user.id })
          allow(REDIS).to receive(:get).and_return(nil)  # Simulate empty cache
          allow(REDIS).to receive(:set)
          allow(user).to receive_message_chain(:notes, :where, :includes, :as_json).and_return(notes.as_json)
        end

        run_test!
      end

      response '401', 'Unauthorized access' do
        let(:Authorization) { 'Bearer invalid.token' }

        before do
          allow(JsonWebToken).to receive(:decode).and_return(nil)  # Invalid token
        end

        run_test!
      end
    end
  end

  path '/api/v1/notes/getNoteById/{id}' do
    get 'Retrieve a note by ID' do
      tags 'Notes'
      security [ BearerAuth: [] ]
      parameter name: :id, in: :path, type: :string, required: true

      response '200', 'Note retrieved successfully' do
        let(:user) { create(:user) }
        let(:note) { create(:note, user: user) }
        let(:id) { note.id }
        let(:Authorization) { "Bearer valid.jwt.token" }

        before do
          allow(JsonWebToken).to receive(:decode).and_return({ id: user.id })
        end

        run_test!
      end

      response '422', 'Note not found or unauthorized' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/api/v1/notes/trashToggle/{id}' do
    put 'Toggle Trash Status' do
      tags 'Notes'
      security [ BearerAuth: [] ]
      parameter name: :id, in: :path, type: :string, required: true

      response '200', 'Trash status toggled' do
        let(:note) { create(:note) }
        let(:id) { note.id }
        run_test!
      end

      response '400', 'Toggle failed' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/api/v1/notes/archiveToggle/{id}' do
    put 'Toggle Archive Status' do
      tags 'Notes'
      security [ BearerAuth: [] ]
      parameter name: :id, in: :path, type: :string, required: true

      response '200', 'Archive status toggled' do
        let(:note) { create(:note) }
        let(:id) { note.id }
        run_test!
      end

      response '400', 'Archive toggle failed' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/api/v1/notes/updateColour/{id}/{colour}' do
    put 'Update note colour' do
      tags 'Notes'
      security [ BearerAuth: [] ]
      parameter name: :id, in: :path, type: :string, required: true
      parameter name: :colour, in: :path, type: :string, required: true

      response '200', 'Colour updated successfully' do
        let(:note) { create(:note) }
        let(:id) { note.id }
        let(:colour) { 'blue' }
        run_test!
      end

      response '400', 'Colour update failed' do
        let(:id) { 'invalid' }
        let(:colour) { 'red' }
        run_test!
      end
    end
  end
end
