class Creature < MObject

  require "./models/special_modules/creature.fight.rb"
  include CreatureFight
  POSITIONS ={
              :stand    => "стоит",
              :sit      => "сидит",
              :died     => "валяется трупом"
              }

  AFFECTS = {
              :invisible       => "невидимость",
              :vision_invisble => "видеть невидимое",
              :magic_armor     => "магическая защита",  # +armor
              :strengthen      => "сила",               # +str
              :weakening       => "слабость",           # -str
              :speedup         => "ускорение",          # +dex
              :slowdown        => "заторможенность",    # -dex
              :paralized       => "паралич"
            }

  GENDERS = {1 => "Female", 0 => "Gender", 2 => "Other"}
  SIDES = ["Ministry", "Dark Mages"]

  # RACES: Ministry Army, Dark Mages, common:
  STATS = ["Сила", "Ловкость", "Выносливость", "Мудрость", "Интеллект"]

  # stats: 1..18, sum=50
  RACES = [
            [ "halfblood",       0, [ 9, 9, 10,  12, 12 ]],
            [ "gnome",             0, [15, 10, 14,  5,  6 ]],
            [ "hobbit",           0, [ 9, 14, 13,  7,  7 ]],
            [ "elf",             0, [ 8, 11,  9, 11, 11 ]],

            [ "troll",           1, [16,  8, 14,  6,  6 ]],
            [ "orc",              1, [11, 14, 10,  7,  6 ]],
            [ "goblin",           1, [ 8,  7,  8, 13, 14 ]],

            [ "pure mage", 2, [ 8,  7,  8, 14, 13 ]],
            [ "human",          2, [11, 11, 11,  9,  8 ]],
            [ "half-giant",      2, [18,  8, 14,  5,  5 ]],
            [ "squib",            2, [10,  9,  9, 11, 11 ]]
          ]

  # messages:
  NO_EXIT = "Вы не можете пройти в эту сторону."
  NO_MOVES = "Вы слишком устали."
  NEED_STAND = "Нужно сначала встать."
  NEED_WAKE_UP = "Нужно сначала проснуться."
  NEED_GET_OUT_OF_FIGHT = "Нужно сначала выйти из боя!"

  SITED_DOWN = "Вы сели."
  ALREADY_SITS = "Вы уже сидите."

  STANDED_UP = "Вы встали."
  ALREADY_STANDS = "Вы уже стоите."

  WENT_TO_SLEEP = "Вы уснули."
  WHILE_SLEEPING = "Вы спите и видите сны..."
  NOT_SLEEPING = "Вы и не спите."
  WAKED_UP = "Вы проснулись."

  attr_accessor :max_health, :max_mana, :max_moves, :round_busy
  attr_reader   :health, :mana, :moves

  def initialize(hash)
    super(hash)

    @side   = hash[:side]        || 0
    @race   = hash[:race]        || 8

    @stats  = hash[:stats]       || RACES[@race][2]

    self.max_health = hash[:max_health] || @stats[2]*10               # hp*10
    self.max_moves  = hash[:max_moves]  || @stats[2]*8 + @stats[1]*2 # con*8 + dex*2
    self.max_mana   = hash[:max_mana]   || @stats[3]*10               # wizd*10

    @health     = hash[:health] || self.max_health
    @moves      = hash[:moves]  || self.max_moves
    @mana       = hash[:mana]   || self.max_mana

    @room_id = hash[:room]||1003
    @affects = hash[:affects]||{}
    @position = hash[:position] || :stand
    @std_position = hash[:std_position] || :stand


    @armor = hash[:armor].to_i||0
    @target = nil
    self.round_busy = 0

    @default_damage_type = hash[:default_damage_type] || "hand"

    set_filters
  end


  def send_fight_log;end
  def long_name(who_ask = false)
    if fighting?
      if self.target!=who_ask
        name.capitalize+" "+f_position+" здесь, сражается с #{self.target.name_forms[4]}."
      else
        name.capitalize+" "+f_position+" здесь, сражается здесь с вами!"
      end
    else
      if !@long_name.nil?
        if position==std_position
          @long_name+"."
        else
          name.capitalize+" "+f_position+" здесь."
        end
      else
        name.capitalize+" "+f_position+" здесь."
      end
    end
  end

  def view;description+"\n\nH#{self.health} M#{self.moves}";end

  def gender;@gender;end
  def male?;@gender==0;end
  def female?;@gender==1;end
  def f_gender;GENDERS[gender]+" пола";end
  def gend(i=0)
    # пришел/шла/шло
    # сказал/ла/ло
    # проснулся/лась/лось
    if male?
      ["ел", "",  "ся",  ""][i]
    elsif female?
      ["ла", "а", "ась", "ла"][i]
    else
      ["ло", "о", "ось", "ло"][i]
    end
  end

  def position;@position;end
  def std_position;@std_position;end
  def f_position;POSITIONS[position];end

  def position=(pos);@position=pos;end

  def stats
    # ["Сила", "Ловкость", "Выносливость", "Мудрость", "Интеллект"]
    @stats
  end

  def race;@race;end
  def side;@side;end

  def health=(x);@health = x.floor;@health = self.max_health if @health > self.max_health;end
  def mana=(x);@mana = x.floor;@mana = self.max_mana if @mana > self.max_mana;end
  def moves=(x);@moves = x.floor;@moves = self.max_moves if @moves > self.max_moves;end

  def sit_down
    unless @position == :sleep
      unless @position == :sit
        @position = :sit
        send SITED_DOWN
        room.visible_creatures(self).each{|cr| cr.send "#{name} сел#{gend(1)} на землю."}
      else
        send ALREADY_SITS
      end
    else
      send NEED_WAKE_UP
    end
  end

  def stand_up
    unless @position == :sleep
      unless @position == :stand
        @position = :stand
        send STANDED_UP
        room.creatures_seeing(self).each{|cr| cr.send "#{name} встал#{gend(1)} на ноги."}
      else
        send ALREADY_STANDS
      end
    else
      send NEED_WAKE_UP
    end
  end

  def go_to_sleep
    unless position == :sleep
      send WENT_TO_SLEEP
      @position = :sleep
      room.creatures_seeing(self).each{|cr| cr.send "#{name} уснул#{gend(1)}."}
    else
      send WHILE_SLEEPING
    end
  end

  def wake_up
    unless position == :sleep
      send NOT_SLEEPING
    else
      @position = :stand
      send WAKED_UP
      room.creatures_seeing(self).each{|cr| cr.send "#{name} проснул#{gend(2)} встал#{gend(1)} на ноги."}
    end
  end

  def affects;@affects;end
  def f_affects
    affects.collect do |aff, sc|
      if sc[1]
        if sc[2]
          left = "еще на #{sc[1]} раундов или #{sc[2]} тиков"
        else
          left = "еще на #{sc[1]} раундов"
        end
      else
        left = "еще на #{sc[2]} тиков"
      end
      "  #{AFFECTS[aff]} (+#{sc[0]}, #{left})"
    end.compact.join("\n")
  end

  def room;Room.find(@room_id);end

  def visible_for(spectator)
    spectator.position != :sleep
  end

  def move(dir)
    if self.moves<=0
      send NO_MOVES
      return false
    end

    if fighting?
      send NEED_GET_OUT_OF_FIGHT
      return false
    end

    if position == :sit
      send NEED_STAND
      return false
    end

    if position == :sleep
      send NEED_WAKE_UP
      return false
    end

    if position == :died
      return false
    end

    to = Room.find(room.exits[dir])
    unless to
      send NO_EXIT
      return false
    end

    (return false) if (to && to.nomob? && self.monster?)

    from = room
    from.creatures_list.delete(self)
    from.save
    to.creatures_seeing(self).each{|cr| cr.send("#{name} приш#{gend} с #{Room::EXITS[Room::EXITS[dir][:anti]][:long]}а")}
    @room_id = to.id
    from.creatures_seeing(self).each{|cr| cr.send("#{name} уш#{gend} на #{Room::EXITS[dir][:long]}")}
    self.moves -= 1
    to.creatures_list.unshift self
    to.save
    save
    return true
  end

  def send(*args);return false;end

  def tell(to, what)
    to.send "#{name} сказал#{gend(1)} вам: \"#{what}\""
    self.send "Вы сказали #{to.name_forms[2]}: \"#{what}\""
  end

  def say(str)
    unless position == :sleep
      self.send "Вы сказали: \"#{str}\""
      self.room.creatures.each do |cr|
        cr.after_say(self, str) unless cr == self
      end
    else
      send NEED_WAKE_UP
    end
  end

  def look(on=false)
    unless position == :sleep
      unless affects[:blind]
        if !on
          out = room.view

          here = ((room.visible_creatures(self).collect{ |cr|  Color.light_red("#{cr.long_name(self)}") })<<room.items.collect{ |it|  Color.light_yellow("#{it.long_name}") }).flatten.compact
          out << "\n\n"+here.join("\n") if here.length>0

          send out
        elsif cr = self.find_by_name_and_room(on, room)
          cr = cr[0]
          send cr.view
        elsif it = Item.find({:name=>on, :room=>room})
          send it[0].view
        else
          send "Не вижу здесь #{on}"
        end
      else
        send "Вы слепы! Вы ничего не видите!"
      end
    else
      send NEED_WAKE_UP
    end
  end

  def find_by_name_and_room(nam, roo)
    crs = roo.visible_creatures(self).collect do |cr|
            cr unless cr.aliases.collect{|a| a.close_to(nam)}.compact.empty?
          end.compact
    if crs.length<1
      return false
    else
      crs
    end
  end

  def take(item)
    send "Вы взяли #{item.name}"
    item.take(self)
  end

  def drop(item)
    send "Вы выбросили #{item.name}"
    item.drop
  end

  def use(item)
    if item.equipable?
      if !equipment || (equipment.collect{|it| it if it.equip==item.equip}.compact.length < Item::EQUIPMENT_TYPES[item.equip][1])
        item.use
        send "Теперь #{item.name} у вас #{Item::EQUIPMENT_TYPES[item.equip][0]}."
      else
        send "Вы уже используете что-то #{Item::EQUIPMENT_TYPES[item.equip][0]}."
      end
    else
      send "Это нельзя использовать."
    end
  end

  def remove(item)
    send "Вы прекратили использовать #{item.name}"
    item.remove
  end

  def inventory;Item.find({:owner => self, :position => :taken});end
  def equipment;Item.find({:owner => self, :position => :equiped});end

  def primary_weapon
    if eq = equipment
      pr = eq.collect{|it| it if it.equiped_on == "right" || it.equiped_on == "both"}.compact
      pr.empty? ? false : pr[0]
    else
      false
    end
  end
=begin
  def offhand_weapon
    if eq = equipment
      off[0] = eq.collect{|it| it if it.equiped_on == "left"}.compact
      off.empty? ? false : off[0]
    else
      false
    end
  end
=end
  def monster?;self.class.to_s == "Monster";end

  # FILTERS ========================================

  def set_filters
    # each fight round
    self.append_filter(:in_round, Proc.new do ||
      if fighting?
        # countdown of affects and freezes
        self.round_busy -= 1 unless self.round_busy==0
        self.affects.each do |aff, a|
          if a[1] && a[1]>0
            self.affects[aff] = [a[0], a[1]-1, a[2]]
          elsif !a[2]
            self.affects.delete(aff)
          end
        end

        self.slash
        # Second attack:
        #self.slash
        # Implement slash( first-prim / second-off[hand] / default )
      end
    end)

    # after slashes
    self.append_filter(:after_round, Proc.new{|| self.send_fight_log })

    # each tick
    self.append_filter(:on_tick, Proc.new do ||
      self.affects.each do |aff, a|
                          if a[2] && a[2]>0
                            self.affects[aff] = [a[0], a[1], a[2]-1]
                          elsif !a[1]
                            self.affects.delete(aff)
                          end
                        end

      if self.online? && (self.health<self.max_health || self.moves<self.max_moves || self.mana<self.max_mana)
        self.health += max_health*0.05 if self.health<self.max_health
        self.moves += max_moves*0.05 if self.moves < self.max_moves
        self.mana += self.max_mana*0.05 if self.mana < self.max_mana
        self.save
      end
      self.send Color.white("     => прошел тик <=")
    end)

    # after someone's death
    self.append_filter(:after_death, Proc.new do |args|
      creature = args[0]

      if fighting? && target == creature
        #$log.info "! #{self.attackers}"
        if self.attackers # && !ats.empty?
          self.target = self.attackers.first
        else
          self.target = nil
        end
      end

      self.send "#{creature.name} помер!"
    end)

    # after_slash(who, targ, hitted?, damage, start?)
    self.append_filter(:after_slash, Proc.new do |args|
      who, tar, start, hit, dam_type, damage = args

      if hit && damage>0
        if who == self
          msg = Color.light_yellow("Вы #{dam_type[0]}и #{tar.name_forms[1]}.")
        elsif tar == self
          msg = Color.light_red("#{who.name} #{dam_type[0]}#{who.gend(1)} Вас.")
        else
          msg = "#{who.name} #{dam_type[0]}#{who.gend(1)} #{tar.name_forms[1]}."
        end
      else
        if who == self
          msg = Color.light_yellow("Вы попытались #{dam_type[1]} #{tar.name_forms[1]}, но промазали.")
        elsif tar == self
          msg = Color.light_red("#{who.name} попытал#{who.gend(2)} #{dam_type[1]} Вас, но промазал#{who.gend(1)}.")
        else
          msg = "#{who.name} попытал#{who.gend(2)} #{dam_type[1]} #{tar.name_forms[1]}, но промазал#{who.gend(1)}."
        end
      end

      if start
        self.send msg
      else
        self.fight_log<<"\n"+msg
        self.save
      end

    end)
    # after_flee(who, succ, [where])
    self.append_filter(:after_flee, Proc.new do |args|
      who, succ, dest = args
      if who == self
        if succ
          self.send "Вы быстро убежали из боя!"
        else
          self.send "Вы не смогли убежать из боя!"
        end
      else
        if succ
          self.send "#{who.name} быстро убежал#{who.gend(1)} из боя!"
          $log.info self.attackers.to_s
          if self.target == who
            self.target = nil
          end
        else
          self.send "#{who.name} попытал#{who.gend(2)} убежать, но не смог#{who.gend(3)}!"
        end
      end

    end)
  end
end
