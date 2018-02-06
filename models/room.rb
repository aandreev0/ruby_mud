class Room
  LITERAL_EXITS = {"south" => "Ю", "north"=>"С",
                    "west" => "З", "east" => "В"}
  TEXTUAL_EXITS = {"south" => "юг", "north"=>"север",
                    "west" => "запад", "east" => "восток"}
  DIRECTIONS    = ["south", "north", "east", "west"]
  ANTIEXITS = {
    "south" => "north",
    "north" => "south",
    "east" => "west",
    "west" => "east"
  }
  def initialize(id, h)
    @title = h["title"]
    @description = h["description"]
    @exits = h["exits"]
    @id = id.to_i
  end
  
  def Room.load
    @@log.info "Loading rooms..."
    @@ROOMS = YAML.load_file( 'db/rooms.yaml' )
    @@log.info "Rooms loaded: #{@@ROOMS.size}"
  end
  
  def Room.find(id)
    if h = @@ROOMS[id.to_i]
      Room.new(id, h)
    end
  end
  
  # instance methods: #  
  def players
    
    return Player.find(:online).collect{|p| p if p.room.id == self.id }.compact
    
  end
  
  def title;@title;end
  def description;@description.chomp+"\n";end
  def exits;@exits;end
  def id;@id;end

  def view(except=false)
    "#{white(title)}\n  #{description}#{f_players(except)}  #{f_exits}"
  end
  
  def f_players(except=false)
    yellow(players.collect{|p| "  #{p.name}\n" if (!except || p!=except)}.compact.join) if players.size>0
  end
  
  def f_exits
    dark_blue("Выходы: "+exits.collect{|e,id| LITERAL_EXITS[e] }.join+">")
  end
  
  def send(msg, sender, msg_to_sender="")
    arr = self.players.collect{|p| p unless p==sender}.compact
    send_to_many_players(msg, arr)
    send_to_char(msg_to_sender, sender) if msg_to_sender!=""
  end
end