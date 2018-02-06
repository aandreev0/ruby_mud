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
    self.encoding = 0
  end

  def player
    Player.find(player_id)[0] if player_id
  end

end
