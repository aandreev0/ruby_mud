def room_say(*args)
  sender, msg = args
  sender.room.send("#{sender.name} сказал: \"#{msg}\"", sender, "Вы сказали: \"#{msg}\"")
end

def yell(*args)
  sender, msg = args
  send_to_all("#{sender.name} крикнул: \"#{msg}\"", sender, "Вы крикнули: \"#{msg}\"")
end

def say(*args)
  sender, t, msg = args
  
  if target = Player.find_by_name(t)
    target = target[0]
    unless sender == target
      if target.online?
        send_to_char("#{sender.name} сказал вам: \"#{msg}\"", target)
        send_to_char("Вы сказали #{target.name}: \"#{msg}\"", sender)
      else
        send_to_char("Он не в сети", sender)
      end
    else
      send_to_char("Самому с собой лучше не разговаривать...", sender)
    end
  else
    send_to_char("Здесь нету \"#{t}\"", sender)
  end

end