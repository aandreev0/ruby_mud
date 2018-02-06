require 'controllers/encoding.rb'
require 'controllers/login.rb'
require 'controllers/explore.rb'
require 'controllers/move.rb'
require 'controllers/tells.rb'
require 'controllers/help.rb'
require 'controllers/admin.rb'

ACTIONS = {
  "кто" => "command_who",
  "смотреть" => "command_look",
  "север" => "go_north",
  "юг" => "go_south",
  "восток" => "go_east",
  "запад" => "go_west",
  "оглядеться" => "do_scan",
  "говорить" => "room_say",
  "справка" => "show_help",
  "reboot" => "reboot_server",
  "сохранить" => "save_players",
  "сказать" => "say",
  "крикнуть" => "yell"
}

UNKNOWN_COMMAND = "Не знаю такой команды"

def parse_command(comm, player)
  comm = comm.gsub(/^\s*/,"").gsub(/\s*$/,"")
  unless comm==""
    action, param1, param2 = comm.split(/\s/, 3)
    @@log.info "Parse `#{comm}`: #{action}(#{param1.to_s}, #{param2.to_s}) from #{player}"
    suc = false
    ACTIONS.each do |al, func|
      if al=~/^#{Regexp.escape(action)}/i
        @@log.info "eval '#{func}(#{player}, \"#{param1.to_s}\", \"#{param2.to_s}\")'"
        eval("#{func}(player, param1.to_s, param2.to_s)")
        
        suc = true
        break
      end
    end
    
    send_to_char(UNKNOWN_COMMAND, player) unless suc
  end
  send_to_socket player.state, player.socket
end