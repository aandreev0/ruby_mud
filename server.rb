require './log/logger.rb'
$log.info ">>> Booting..."

require 'active_support'
$KCODE = 'u'

require './helpers/colors.rb'
require './helpers/randomizer.rb'

require './models/mobject.rb'
require './models/creature.rb'
require './models/player.rb'
require './models/monster.rb'
require './models/item.rb'
require './models/magic.rb'

require './models/special_modules/index.rb'

require './models/room.rb'
require './db/base.rb'
require './models/event.rb'

require './controllers/parser.rb'

require 'gserver'
require 'yaml'
require './models/TCPSocket.rb'
require './models/hash.rb'


class MULServer < GServer
  def initialize(port=16666, host=GServer::DEFAULT_HOST)

    $log.info " ---=== Server initialized ===---"
    super(port, host, Float::MAX, $stderr, true)
    DataBase.load
    Event.each_pulse
    Event.each_round
    Event.each_tick

    $log.info "Server pulse: #{Event::PULSE}\n"+
              "Server round: #{Event::ROUND}\n".rjust(40)+
              "Server tick: #{Event::TICK}\n".rjust(40)
  end

  def serve(socket)
    begin
      $log.info "Connected socket #{socket}"
      socket.select_encoding

      until socket.closed? || socket.eof? do

        if socket.encoding || socket.select_encoding(socket.gets.chop)
          break if socket.login_step == :kick || socket.closed?

          input = socket.get.chop
          socket.login_data ||= {}
          if socket.login_step==:logged || ((socket=Player.login(input, socket)).login_step==:logged && input = nil)
            player = socket.player
            Parser.parse(input, player)
          end

        end
      end
    rescue
      $log.info $!
      socket.close
      socket = nil
      stop()
    ensure
      $log.info "disconnected #{socket.inspect}"
      if socket.player
        socket.player.exit
      end
      socket.close
      socket = nil
    end

  end
end




server = MULServer.new 666, "127.0.0.1"
server.audit = true
server.start(-1)
server.join
