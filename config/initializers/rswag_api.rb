Rswag::Api.configure do |c|
  # Set the root folder where Swagger JSON files are located
  c.openapi_root = File.join(Rails.root, "swagger")

  # Optionally, use a filter to dynamically alter the Swagger before serialization
  # c.swagger_filter = lambda { |swagger, env| swagger['host'] = env['HTTP_HOST'] }
end