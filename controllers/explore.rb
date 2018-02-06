def command_who(*args)
  player, target = args
  begin
    if target.to_s==""
      send_to_char("Зарегистрированные игроки:\n"+Player.find(:all).collect{|pl| " #{pl.name} #{pl.state} (#{pl.online? ? "онлайн" : "офлайн"})" }.join("\n"), player)
    elsif "онлайн" =~ /^#{target}/
      send_to_char("Игроки онлайн:\n"+Player.find(:online).collect{|pl| " #{pl.name}"}.join("\n"), player)
    elsif ar = Player.find_by_name(target)
      send_to_char("Игроки онлайн =~ #{target}:\n"+ar.collect{|pl| " #{pl.name} (#{pl.online? ? "онлайн" : "офлайн"})"}.join("\n"), player)
    else
      send_to_char("Нету никого с именем #{target}", player)
    end
  rescue
    @@log.warn $!
  end  
end

def command_look(*args)
  player, target = args
  
  send_to_char(if target.nil? || target ==""
      player.room.view(player)
    else
      "Не вижу #{target} здесь"
    end, player)
end

def do_scan(*args)
  player, tar = args
  send_to_char(white("Вы огляделись по сторонам:\n")+player.room.exits.collect do |e,id| 
    if r = Room.find(id)
      "  #{Room::TEXTUAL_EXITS[e]}:".ljust(10)+" #{r.title}\n#{r.f_players}"
    end
  end.join, player)
end