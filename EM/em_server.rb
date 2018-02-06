require 'rubygems'
require 'eventmachine'

require 'helpers/colors.rb'
require 'log/logger.rb'
require 'iconv'

require 'senders/main.rb'

require 'models/player.rb'
require 'models/room.rb'
require 'models/thing.rb'
require 'models/event.rb'

require 'controllers/parser.rb'


require 'yaml'

class MULServer
  attr_accessor :clients
  def initialize
    Room.load
    Thing.load
    Player.load
    Event.each_tick
  end
  
  def run
    s = self
    EM::start_server('0.0.0.0', 666, MULClient){|con|
      con.server = s
    }
  end
  
end

module MULClient
  attr_accessor :server, :encoding, :login_step
  
  def post_init
    puts "#{self.inspect} connected."
  end
  
  def receive_data(data)
    #puts "Received #{data.size} bytes"
    #send_data(data)
    
    puts "#{self.inspect} connected."
    
    server.clients[self.object_id] = self
    
    get_encoding(false, self)
    
    if get_encoding(inp, self)
      inp = encode(data, 'UTF-8', self.encoding)
      if sock.login_step == :logged_in || (l=login(inp, self)) == :logged_in
        # play
        parse_command(inp, l[1])
      elsif l[0]!=nil && l[0] == :exit
        break
      end
    end
    
  end
  
  def unbind
    puts "client disconnected"
  end
  
end

server = MULServer.new

EM::run do
  server.run
end