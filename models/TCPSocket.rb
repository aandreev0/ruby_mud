class TCPSocket
  attr_accessor :encoding, :login_step, :login_data, :player_id

  def put(msg)
    begin
      self.putr msg.to_s
    rescue
      $log.info "TCPSocket err: "+$!
    end
  end

  def putr(str)
    print str.gsub(/\n/, "\n\r") unless closed?
  end

  def get
    str = self.gets
    $log.info str
    return str
  end

  def select_encoding(inp=false)
    encs = {"0" => ["utf-8", "utf-8"],
            "1" => ["cp1251", "cp1251: windows client (e.g. JMC)"],
            "2" => ["koi8-r", "koi8-r: telnet"]}
    if inp
      if encs[inp]
        self.encoding = encs[inp][0]
        self.put "Вы выбрали кодировку \"#{encoding}\"\n"
        Player.login(nil, self)
        #true
      else
        self.putr "No such encoding"
        self.putr encs.collect{|k,e| "#{k}. #{e[1]}" }.join("\n")
        false
      end
    else
      self.putr encs.collect{|k, e| "#{k}. #{e[1]}" }.join("\n")
    end
  end

  def player
    Player.find(player_id)[0] if player_id
  end

end
