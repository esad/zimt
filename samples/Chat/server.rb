require 'rubygems'
require 'em-websocket'


EventMachine.run {
  @channel = EM::Channel.new

  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 10_000, :debug => true) do |ws|
    ws.onopen {
      @sid = @channel.subscribe { |msg| ws.send msg }
      @channel.push "#{@sid} connected!"
    }

    ws.onmessage { |msg|
      @channel.push "#{@sid}: #{msg}"
    }

    ws.onclose {
      puts "#{@sid} gone"
      @channel.unsubscribe(@sid)
    }
  end

  puts "Server started"
  
  Thread.new do
     while(true) do
        @channel.push "Server: ping"
        sleep 1
      end
  end
}
