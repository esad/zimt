require 'rubygems'
require 'em-websocket'

EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 10_000, :debug => true) do |ws|
  ws.onopen    do 
    ws.send "Hello there, stranger!"
    Thread.new do 
      while(true) do
        ws.send "Ping"
        sleep 1
      end
    end
  end
  
  ws.onmessage do |msg| 
    sleep rand
    reply = rand(3)
    case reply
      when 0
        ws.send "Yeah? Go on..."
      when 1
        ws.send "#{msg}? Funny.."
      when 2
        ws.send "You know, I don't really want to discuss this"
    end
  end
end
