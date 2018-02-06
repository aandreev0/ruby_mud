require './controllers/commands.rb'

module Parser

  @@UNKNOWN = "Don't know this command"
  @@NO = "Hmm?"

  def Parser.parse(str, player) # what, from
    str = str.gsub(/^\s*/,"").gsub(/\s*$/,"")

    unless str == ""
      action, params = str.split(/\s/, 2)
      suc = false
      Commands::LIST.each do |k, f|
        if k=~/^#{Regexp.escape(action)}/i
          eval("Commands.#{f}(player, params)")
          suc = true
          break
        end
      end
      player.send @@UNKNOWN unless suc
    else
      player.send @@NO
    end

  end
end
