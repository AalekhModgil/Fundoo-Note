# frozen_string_literal: true

require 'rails_helper'
require 'rswag/api'
require 'rswag/specs'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON/YAML files are generated
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Fundoo Notes API',
        version: 'v1',
        description: 'API documentation for Fundoo Notes, including authentication and note management.'
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Local Development Server'
        }
      ],
      components: {
        securitySchemes: {
          BearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          }
        }
      },
      security: [{ BearerAuth: [] }]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  config.openapi_format = :yaml
end