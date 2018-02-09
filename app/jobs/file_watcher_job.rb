class FileWatcherJob < ApplicationJob
  queue_as :default
  include FileTail

  def perform(path)
    @clients = []
    EM::WebSocket.start(:host => '0.0.0.0', :port => '3008') do |ws|
      ws.onopen do |handshake|
        @clients << ws
        ws.send "Connected to #{handshake.path}."
      end

      ws.onclose do
        ws.send "Closed."
        @clients.delete ws
      end

      ws.onmessage do |msg|
        puts "Received Message: #{msg}"
        @clients.each do |socket|
          socket.send msg
        end
      end
    end
    watch_file(path)
  end


  private

    def watch_file(path)
      loop do
        f = File.open(path, "r")
        new_hash = File.stat(f).mtime.to_i
        hash ||= new_hash
        diff_hash = new_hash - hash

        if diff_hash.present?
          hash = new_hash
          EM.run do
            ws = EventMachine::WebSocketClient.connect("ws://localhost:3000")
            ws.callback do
              ws.send_msg(tail(path, 10))
            end
          end
        end
      end
    end
end
