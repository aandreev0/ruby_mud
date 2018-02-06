def send_to_socket(*args)
  msg, to = args
  to.puts encode(msg, to.encoding,'UTF-8').gsub(/\n/,"\n\r")+"\r"
end

def send_to_char(msg, pl)
  send_to_socket(msg, pl.socket)
end

def send_to_all(*args)
  from = false
  msg, from = args
  @@log.info "Send '#{msg}' to all from #{from ? from : 'server' }"
  @@CLIENTS.each { |i, c|
    send_to_socket(msg, c) if (from && c!=from) || !from
  }
end

def send_to_many_players(msg, arr)
  arr.each do |player|
    send_to_socket(msg, player.socket)
  end
end

def encode(msg, to, from)
  if to == "cp1251-ya-fix"
    msg = msg.gsub(/я/,"яя")
    to = "cp1251"
  end
  
  from = "cp1251" if from == "cp1251-ya-fix"
  
  Iconv.new(to, from).iconv(msg)
end