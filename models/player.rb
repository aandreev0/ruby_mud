
@@PLAYERS = Hash.new

class Player
  
  attr_accessor :health, :socket, :name, :password

  def initialize(h)
    @name = h[:name]
    @socket = h[:socket]
    @room = (h[:room] || 1)
    @name = h[:name]
    @health = (h[:health]||100)
    @moves =(h[:moves]||100)
    @password = h[:password]
    @@log.info "Initialized player '#{@name}'"
  end
  
  def moves;@moves;end
  def moves=(m);@moves = m;end
  
  def ==(other)
    self.name==other.name
  end
  
  def Player.find_or_create_by_name(h)
    @@log.info "Find or create by name player '#{h[:name]}'"
    
    if pl = Player.find(h)
      @@log.info "Player '#{pl.name}' found!"
      return pl
    else
      @@log.info "Creating player '#{h[:name]}'"
      pl = Player.new(h)
      pl.save
      return pl
    end
  end
  
  def state
    yellow("< H#{health} M#{moves} >")
  end
  
  def Player.load
    File.open( 'db/players.yaml' ) do |yf|
      pls = YAML::load( yf )
      @@log.info "Pls: #{pls.inspect}"
      pls = Hash.new unless pls
      pls.each{|k,v| @@PLAYERS[k]=Player.new(v) }
      @@log.info "Players: #{@@PLAYERS.inspect}"
    end
    
    
  end
  
  def Player.find(h)
    if h==:all
      @@PLAYERS.collect{|n,pl| pl }
    elsif h==:online
      @@PLAYERS.collect do |n,pl|
        pl if pl.online?
      end.compact
    else
      if @@PLAYERS.include?(h[:name])
        @@PLAYERS[h[:name]]
      else
        false
      end
    end
  end
  
  def Player.find_by_name(name)
    p = @@PLAYERS.collect{|n,p| p if n=~/^#{name}/ }.compact
    if p.empty?
      return false 
    else
      p
    end
  end
  
  def Player.save_all
    File.open( 'db/players.yaml', 'w' ) do |out|
      d = Hash.new
      @@PLAYERS.each{|n, pl|  d[pl.name] = {:name=>pl.name,
                                                :room=>pl.room.id,
                                                :password=>pl.password,
                                                :health=>pl.health,
                                                :moves=>pl.moves}
      }
      YAML.dump( d, out )
    end
  end
  
  def save
    @@PLAYERS[self.name] = Player.new({:name=>@name,
                                        :socket=>@socket,
                                        :room=>@room,
                                        :password=>@password,
                                        :health=>@health,
                                        :moves=>@moves})
    true
  end
  
  def online?
    return @@CLIENTS.has_value?(self.socket)
  end
  
  def room
    Room.find(@room)
  end
  
  def room=(r)
    @room = r.id
  end
  
  def move(dir)
    if self.moves>0
      if r = Room.find(self.room.exits[dir])
        self.room.send("#{self.name} ушел на #{Room::TEXTUAL_EXITS[dir]}", self)
        r.send("#{self.name} пришел с #{Room::TEXTUAL_EXITS[Room::ANTIEXITS[dir]]}а", self)
        self.moves -= 1
        self.room = r
        self.save
      else
        send_to_char('Вы не можете туда пройти.', self)
      end
    else
      self.room.send("#{self.name} очень устал!", self,"Вы слишком устали, чтобы двигаться!")
    end
  end
  
  def rest
    if self.moves<100
      self.moves += 5
      self.moves = 100 if self.moves>100
    end
    self.save
  end
  
end