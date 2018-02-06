require 'helpers/colors.rb'
require 'log/logger.rb'
require 'iconv'

require 'senders/main.rb'

require 'models/player.rb'
require 'models/room.rb'
require 'models/thing.rb'
require 'models/event.rb'

require 'controllers/parser.rb'

require 'gserver'
require 'yaml'



@@CLIENTS = {}
class GameServer < GServer
  def initialize(port=666, host=GServer::DEFAULT_HOST)

    Room.load
    Thing.load
    Player.load
    
    @@log.info "Server initialized"
    super(port, host, Float::MAX, $stderr, true)
    Event.each_tick
    
  end
  
  def serve(sock)
    begin
      @@CLIENTS[sock.object_id] = sock
      get_encoding(false, sock)
      
      until sock.eof? do
        inp = sock.gets.chomp
        
        if get_encoding(inp, sock)
          inp = encode(inp, 'UTF-8', sock.encoding)
          
          if (l = login(inp, sock))[0] == :logged_in
            parse_command(inp, l[1])
            sleep 4 if rand(4) ==0
          elsif l[0]!=nil && l[0] == :exit
            break
          end
          
        end
      end
    rescue
      @@log.warn $!
      stop()
    ensure
      @@log.info "Disconnected #{sock}"
      @@CLIENTS.delete(sock.object_id)
    end
  end
end

class TCPSocket
  attr_accessor :encoding, :login_step, :char_name
end

@@server = GameServer.new 666  , "127.0.0.1"
@@server.audit = true
@@server.start(-1)
@@server.join