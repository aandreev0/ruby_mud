def get_encoding(*args)
  inp, sock = args
  return true if sock.encoding
  
  encodings = {"0"=>["utf-8", ""],
             "1"=>["cp1251", "(Win client)"],
             "2"=>["koi8-r" ,"(Telnet)"],
             "3"=>["cp1251-ya-fix", "(Win client, if no YA shown)"]}
  
  out = "Choose your encoding: \n\r"+encodings.collect{|i, e| " #{i}) #{e[0]} #{e[1]}" }.join("\n\r")
  
  if inp == false
    sock.print out
  else
    if encodings[inp]
      sock.puts encodings[inp][0]+" chosen\n\r"
      sock.encoding = encodings[inp][0]
      true
    else
      sock.puts "Please, choose from the list above.\n\r"
      false
    end
  end

end