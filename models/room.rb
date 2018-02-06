class Room < MObject
  EXITS = {
    "north" => {:long=>"север",  :short_rus => "С", :short_eng => "N", :anti=>"south", :to => "на север"}, 
    "south" => {:long=>"юг",     :short_rus => "Ю", :short_eng => "S", :anti=>"north", :to => "на юг"}, 
    "west"  => {:long=>"запад",  :short_rus => "З", :short_eng => "W", :anti=>"east",  :to => "на запад" }, 
    "east"  => {:long=>"восток", :short_rus => "В", :short_eng => "E", :anti=>"west",  :to => "на восток" },
    "up"    => {:long=>"вверх",  :short_rus => "^", :short_eng => "^", :anti=>"down",  :to => "наверх"},
    "down"  => {:long=>"вниз",   :short_rus => "V", :short_eng => "V", :anti=>"up",    :to => "вниз"}
  }
  
  attr_accessor :creatures_list, :items_list
  
  def initialize(hash)
    self.creatures_list = []
    self.items_list = []
    @title = hash[:title]
    @description = hash[:description].chop
    @id = hash[:id].to_i
    @exits = {}
    @flags = hash[:flags].split(" ")||[]
    EXITS.each{|k,h| @exits[k] = hash[:exits][k.to_s] unless hash[:exits][k.to_s].nil? }
    
    if loading_monsters = hash[:monsters]
      loading_monsters.each do |monster|
        id, updates = monster
        h = DataBase.monsters_prototypes[id].dup
        ups = {:room => @id}
        updates.each{|k,v| ups[k] = v } if updates
        
        m = Monster.new(h.update(ups))
        m.save
        self.creatures_list << m
      end
    end

    if loading_items = hash[:items]
      $log.info "R=> #{loading_items.length}"
      loading_items.each do |id, updates|
        h = DataBase.items_prototypes[id].dup
        ups = {:room => @id, :position=>:lie, :owner=>nil}
        ups.update(updates) if updates
        Item.new(h.update(ups)).save
      end
    end
    
  end
  def id;@id;end
  
  def exits;@exits;end
  
  def random_exit
    availiable = exits.keys.collect{|k| k if Room.find(exits[k]) }.compact
    availiable[rand(availiable.length)]
  end
  
  def zmud_exits
    "["+(@exits.collect{|k, v| EXITS[k][:short_eng] }.join(" "))+"]"
  end
  
  def short_exits
    @exits.collect{|k, v| EXITS[k][:short_rus] }.join
  end
  
  def view(*exept)
    "#{Color.light_blue(@title)}\n  #{@description}"
  end
  
  def Room.find(id)
    DataBase.rooms[id.to_i]
  end
  
  def players
    DataBase.players.collect{|id, pl| pl if pl.room == self }.compact
  end
  
  def monsters
    DataBase.monsters.collect{|id, mo| mo if mo.room == self }.compact
  end
  
  def items
    r = Item.find({:room => self})
    if r
      r
    else
     []
    end
  end
  
  def creatures
    self.creatures_list.collect{|cr| cr if cr.position != :died }.compact
  end
  
  def visible_creatures(creature)
    self.creatures_list.collect{|cr| cr if cr!=creature && !cr.nil? && cr.online? && cr.visible_for(creature) }.compact
  end
  
  def creatures_seeing(creature)
    self.creatures_list.collect{|cr| cr if cr!=creature && !cr.nil? && cr.online? && creature.visible_for(cr) }.compact
  end
  
  def send(str)
    players.each{|pl| pl.send str}
  end
  
  def save
    DataBase.save_room(self)
  end
  
  # FLAGS:
  
  def light?;@flags.include?("light");end
  def nomob?;@flags.include?("nomob");end
  def peaceful?;false;end
  
end