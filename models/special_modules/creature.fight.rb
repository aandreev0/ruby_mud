module CreatureFight
  
  # Implement creature's fight methods
  def target;@target;end
  def target=(cr)
    if cr!=nil
      @target = cr
      DataBase.fighters << self unless DataBase.fighters.include?(self)
    else
      @target = nil
      DataBase.fighters.delete self
    end
    self.save
  end
  
  def attack(creature) # начать бой
    if !fighting?
      self.target = creature
      unless creature.fighting?
        creature.target = self
      end
      slash(true)
    else
      send "Вы уже сражаетесь!"
    end
    
  end
  
  def slash(start = false)
    if fighting?
      skill = 0
      hit = (10 + self.dex+skill/0.2 - self.target.dex >= rand(21)+1 )
      
      if primary_weapon
        dam_type = primary_weapon.damage_type
      else
        dam_type = @default_damage_type
      end
      dam_type = Item::DAMAGE_TYPES[dam_type]
      
      if !hit
        room.creatures.each do |cr|
          cr.after_slash(self, target, start, hit, dam_type)
        end
        
      else # hitted
        
        damage = ((Randomizer.roll("2d3") + stats[0]/8)*(1 - target.armor)).ceil
        
        self.target.health -= damage
        if self.target.health>0
          room.creatures.each do |cr|
            cr.after_slash(self, target, start, hit, dam_type, damage)
          end
        else # killed
          # ...
        end
        self.target.save
      end
    else
      send "Да вы ни на кого и не нападали..."
    end
  end
  
  def flee
    if fighting?
      from = self.room
      to = room.random_exit
      
      if rand(2)==0
        self.target = nil
        room.creatures.each do |cr|
          cr.after_flee(self, true, to)
        end
        self.move(to)
      else
        room.creatures.each do |cr|
          cr.after_flee(self, false)
        end
      end
    else
      send "Вы ни с кем не деретесь."
    end
  end
  
  def fighting?; self.target!=nil;end
  def attackers;room.creatures.collect{|cr| cr if cr.target == self}.compact;end
  
  # fight stats recount
  def armor
    a = @armor
    a += affects[:magic_armor][0] if affects[:magic_armor]
    a = 50 if a>50
    a/100.0
  end
  
  def dex
    d = @stats[1]
    d + affects[:speedup][0] if affects[:speedup]
    d
  end
  
end