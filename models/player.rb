class Player < Creature

  attr_accessor :socket, :fight_log

  REG_GENDERS = ["m", "f"]
  NAMES_FORMS_QUESTIONS = ["Р) ударить кого", "Д) говорю кому", "В) вижу кого", "Т) убит кем", "П) думаю о ком"]

  def initialize(hash)
    super(hash)
    @password = hash[:password].to_s.chars
    @logged_in = false
    self.fight_log = ""
    set_player_filters

  end

  def logged_in=(b)
    @logged_in = b
    room.creatures_list << self if b && !room.creatures_list.include?(self)
  end
  def logged_in;@logged_in;end

  def send_fight_log
    unless self.fight_log==""
      send self.fight_log
      self.fight_log = ""
      self.save
    end
  end

  def titled_name
    "#{Creature::RACES[race][0]} #{name}"
  end

  def scores

    st = []
    Creature::STATS.each_index{|ind| st<< "#{Creature::STATS[ind].chars.ljust(12)} #{stats[ind]}" }
    st = st.join("\n                ")

    send ("Вы "+Color.light_yellow(titled_name)+
    "\nФормы вашего имени: #{f_names_forms}\n"+
    "Вы связаны с организацией \"#{Creature::SIDES[side]}\"\n"+
    "Вы имеет #{self.health}(#{self.max_health}) единиц жизней, #{self.moves}(#{self.max_moves}) энергии, #{self.mana}(#{self.max_mana}) маны\n"+
    "#{Color.white("Характеристики")}: #{st}\n")+
    "Аффекты:\n#{f_affects}"
  end

  def password;@password;end

  def state
    "#{Color.number(self.health, self.max_health, "H#{self.health}")} #{Color.number(self.moves, self.max_moves, "E#{self.moves}")} #{Color.number(self.mana, self.max_mana, "M#{self.mana}")}#{fight_state} Вых:#{(room.short_exits if position!=:sleep && !affects[:blind]).to_s}> "
  end

  def fight_state
    ""
    " [#{name}: #{Color.number(self.health, self.max_health, "#{(100*self.health/self.max_health).round}%")}] [#{self.target.name}: #{Color.number(self.target.health, self.target.max_health, "#{(100*self.target.health/self.target.max_health).round}%")}]" if fighting?
  end

  def send(msg, *args)
    if online?
      socket.put msg+"\n\n"+state
    end
  end

  def scan
    unless position == :sleep
      out = Color.white "Вы огляделись по сторонам:"
      room.exits.each do |k, r|
        if ro = Room.find(r)
          out << Color.white("\n  На #{Room::EXITS[k][:long]}е:\n")
          crs = ro.creatures.collect{|cr| Color.light_red("    #{cr.long_name}") if cr.online? && cr.visible_for(self) }.compact
          out << (crs.length>0 ? crs.join("\n") : "    никого")
        end
      end
      send out
    else
      send Creature::NEED_WAKE_UP
    end
  end

  def online?
    (!socket.nil? && !socket.closed? && logged_in)
  end

  def exit
    fight_log = ""
    @socket.close
    @logged_in = false
    @socket = nil
    save
  end

  def save
    DataBase.save_player self
  end

  def Player.find(q)
    res = []
    if q == :online
      res = DataBase.players.collect{|id, pl| pl if pl.online? }.compact
    elsif q == :all
      res = DataBase.players.collect{|id, pl| pl}
    elsif q.class.to_s=="Hash"
      res = DataBase.players.collect do |id, pl|
        pl if (!q[:name] || pl.name == q[:name])
      end.compact
    elsif q.class.to_s=="Fixnum"
      res = [DataBase.players[q]] if DataBase.players[q]
    end

    res = false if res.empty?
    res
  end

  def set_player_filters
    self.append_filter(:after_say, Proc.new{|who, what| self.send "#{who.name} сказал#{who.gend(1)}: \"#{what}\"" })
  end

  def inventory_view
    if self.inventory
      out = Color.white("Вы несете:")+"\n"+(self.inventory.collect{|it| " #{it.name}" }.join("\n"))
    else
      out = Color.white("В карманах пусто :-(")
    end
    send out
  end

  def equipment_view
    if self.equipment
      out = Color.white("Вы используете:")+"\n"+(self.equipment.collect{|it| "< #{Item::EQUIPMENT_TYPES[it.equiped_on][0]} > #{it.name}" }.join("\n"))
    else
      out = Color.white("Вы голы как соколы :-(")
    end
    send out
  end

  def hash4save
    {
    :room         => room.id,
    :password     => password.to_s,
    :health       => self.health,
    :max_health   => self.max_health,
    :moves        => self.moves,
    :max_moves    => self.max_moves,
    :mana         => self.mana,
    :max_mana     => self.max_mana,
    :affects      => affects,
    :position     => position,
    :gender       => gender.to_s,
    :name_forms   => name_forms.collect{|n| n.to_s},
    :description  => description.to_s,
    :race         => race.to_i,
    :side         => side.to_i,
    :stats        => stats
    }
  end

end
