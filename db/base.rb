module DataBase
  
  PREF = "DB: "
  
  def DataBase.load
    
    @players = {}
    
    @monsters_prototypes = {}
    @items_prototypes = {}
    
    @items = {}
    @monsters = {}
    
    @rooms = {}
    
    @fighters = []
    
    $log.info PREF+"=> Loading monsters prototypes..."
    File.open( 'db/monsters_prototypes.yaml' ) do |yf|
      pls = YAML::load( yf )
      pls = Hash.new unless pls
      pls.each{|id, hash| @monsters_prototypes[id] = hash.update({:id=>id})}
    end
    $log.info PREF+"   Loaded #{@monsters_prototypes.length} monsters prototypes."
    
    $log.info PREF+"=> Loading items prorotypes..."
    File.open( 'db/items_prototypes.yaml' ) do |yf|
      pls = YAML::load( yf )
      pls = Hash.new unless pls
      pls.each{|id, hash| @items_prototypes[id] = hash}
    end
    $log.info PREF+"   Loaded #{@items_prototypes.length} items prorotypes."
    
    $log.info PREF+"=> Loading rooms..."
    Dir.foreach("db/zones") do |z_f|
      if FileTest.file?("db/zones/#{z_f}")
        $log.info "Loading zone from #{z_f}..."
        rooms = YAML.load_file("db/zones/#{z_f}")
        if rooms
        rooms.each{|id, data|
          @rooms[id.to_i] = Room.new(data.update({:id => id}))
        }
        end
        $log.info "loaded #{rooms ? rooms.length : 0} rooms"
      end
    end
    $log.info PREF+"   Loaded #{@rooms.length} rooms."
    $log.info PREF+"   Loaded #{@items.length} items: #{@items.collect{|id, it| id}.join(", ")}."
    
    
    $log.info PREF+"=> Loading players..."
    File.open( 'db/players.yaml' ) do |yf|
      pls = YAML::load( yf )
      pls = Hash.new unless pls
      pls.each{|id, hash| @players[id.to_i] = Player.new(hash.update({:id=>id.to_i}))}
    end
    $log.info PREF+"   Loaded #{@players.length} players"
  end
  
  def DataBase.dump
    DataBase.dump_players
    DataBase.dump_items
    DataBase.dump_monsters
  end
  
  def DataBase.save_player(player)
    player.id = (DataBase.players.empty? ? 0 : DataBase.players.keys.last+1) unless player.id
    DataBase.players[player.id] = player
  end
  
  def DataBase.dump_players
    File.open( 'db/players.yaml', 'w' ) do |out|
      d = Hash.new
      @players.each{|id, pl|  d[id] = pl.hash4save }
      YAML.dump( d, out )
    end
  end
  
  def DataBase.dump_items
    File.open( 'db/items.yaml', 'w' ) do |out|
      d = Hash.new
      @items.each{|id, item|  d[id] = item.hash4save }
      YAML.dump( d, out )
    end
  end
  
  def DataBase.dump_monsters
    File.open( 'db/monsters.yaml', 'w' ) do |out|
      d = Hash.new
      @monsters.each{|id, mn|  d[id] = mn.hash4save }
      YAML.dump( d, out )
    end
  end
  
  def DataBase.save_monster(monst)
    monst.id = (DataBase.monsters.empty? ? 0 : DataBase.monsters.keys.last+1) unless monst.id
    DataBase.monsters[monst.id] = monst
  end
  
  def DataBase.delete_monster(monst)
    DataBase.monsters.delete(monst.id)
    monst = nil
  end
  
  def DataBase.rooms;@rooms;end
  def DataBase.save_room(r); @rooms[r.id.to_i] = r;end
  
  def DataBase.players;@players;end
  
  def DataBase.monsters_prototypes;@monsters_prototypes;end
  def DataBase.monsters;@monsters;end
  
  # ITEMS:
  def DataBase.items_prototypes;@items_prototypes;end
  def DataBase.items;@items;end
  
  def DataBase.save_item(item)
    $log.info "<= item #{item.id}"
    item.id = (DataBase.items.empty? ? 1 : DataBase.items.keys.last.to_i+1)# unless item.id
    $log.info "save item #{item.id}"
    DataBase.items[item.id] = item
  end
  
  #def DataBase.creatures;DataBase.players.update(DataBase.monsters);end
  
  def DataBase.fighters;@fighters;end
end