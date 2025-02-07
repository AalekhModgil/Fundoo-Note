require 'bunny'

module RabbitMQ
  def self.create_channel
    connection = Bunny.new(hostname: "localhost")
    connection.start
    channel = connection.create_channel
    channel
  end
end
