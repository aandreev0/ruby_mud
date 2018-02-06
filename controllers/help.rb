def show_help(*args)
  pl, topic = args
  if topic==""
    
    help = white("СПРАВКА\n")+"\nВсе топики:\n"+ACTIONS.collect{|k,v| "  #{k}" }.join("\n")
    
    send_to_char(help, pl)
  else
    send_to_char("Нету справки про #{topic}", pl)
  end
end