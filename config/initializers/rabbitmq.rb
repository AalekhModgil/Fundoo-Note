require 'bunny'

# This module establishes a connection to RabbitMQ and creates a channel to communicate with it.
module RabbitMQ
  def self.create_channel
    connection = Bunny.new(hostname: "localhost") # Connect to RabbitMQ server
    connection.start  # Start the connection
    channel = connection.create_channel  # Create a channel for communication
    channel
  end
end
