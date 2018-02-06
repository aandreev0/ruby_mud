class Magic
  
  SPELLS = {
            "огненныйшар" => "fireball",
            "ускорение"   => "speedup",
            "защита"      => "armor",
            "исцеление"   => "heal"
            }
  
end

module Spell
  
  def Spell.fireball(caster, target)
    
    cost = 5
    unless target || target = caster.target
      caster.send "На кого вы хотите наслать #{Color.light_red("огненный шар?")}"
      return
    end
    if caster.mana >= cost
      caster.mana -= cost
      damage = 2 + Randomizer.roll("1d6")
      
      target.health -= damage
      if target.health > 0
        caster.send Color.light_yellow("Огненный шар, выпущенный вами, ударил прямо в грудь #{target.name_forms[1]}.")
        target.send Color.light_red("Огненный шар, выпущенный #{caster.name_forms[4]}, ударил прямо в вашу грудь!")
        caster.room.creatures.each do |cr|
          if cr!=caster && cr!=target && cr.online? && caster.visible_for(cr)
            cr.send "Огненный шар, выпущенный #{caster.name_forms[4]}, ударил прямо в грудь #{target.name_forms[1]}."
          end
        end
        unless target.fighting?
          target.attack caster
        end
        
      else
        caster.send Color.light_yellow("Огненный шар, выпущенный вами, спалил #{target.name_forms[1]} до тла!")
        target.send Color.light_red("Огненный шар, выпущенный #{caster.name_forms[4]}, спалил вас до тла!")
        caster.room.creatures.each do |cr|
          if cr!=caster && cr!=target && cr.online? && caster.visible_for(cr)
            cr.send("Огненный шар, выпущенный #{caster.name_forms[4]}, спалил #{target.name_forms[3]} до тла.")
            cr.save
          end
        end
      end
      caster.round_busy = 1
      caster.save
      target.save
      
    else
      caster.send "У вас не хватает маны для создания #{Color.light_red("огненого шара")}."
    end
  end
  
  def Spell.speedup(caster, target)
    mana = 15
    if caster.mana >= mana
      target ||= caster
      caster.mana -= mana
      caster==target ? af="Вы стали двигаться быстрее." : af="#{target.name} стал#{target.gend(1)} двигаться быстрее."
      caster.send "Вы произнесли #{Color.light_green("заклинание ускорения")}.\n"+af
      
      target.affects[:speedup] = [Randomizer.roll("1d2")+1, false, 10]
      caster.room.creatures_seeing(target).each{|cr| cr.send "#{caster.name} прознес #{Color.light_green("заклинание ускорения")}.\n#{target.name} стал#{target.gend(1)} двигаться быстрее." if cr!=caster }
      target.save
      caster.save
    else
      caster.send "У вас не хватает маны для произнесения #{Color.light_green("заклинания ускорения")}."
    end
  end
  
  def Spell.armor(caster, target)
    mana = 25
    if caster.mana >= mana
      target ||= caster
      caster.mana -= mana
      caster==target ? af="Вы стали защищеннее." : af="#{target.name} стал#{target.gend(1)} защищеннее."
      caster.send "Вы произнесли #{Color.light_yellow("заклинание защиты")}.\n"+af
      
      target.affects[:magic_armor] = [Randomizer.roll("1d2")+10, false, 10]
      caster.room.creatures_seeing(target).each{|cr| cr.send "#{caster.name} прознес #{Color.light_yellow("заклинание защиты")}.\n#{target.name} стал#{target.gend(1)} защищеннее." if cr!=caster }
      target.save
      caster.save
    else
      caster.send "У вас не хватает маны для произнесения #{Color.light_yellow("заклинания защиты")}."
    end
  end
  
  def Spell.heal(caster, target)
    target ||= caster
    mana = 10
    if caster.mana >= mana
      caster.mana -= 10
      target.health += Randomizer.roll("2d4")+5
      af = ''
      af="\nВы почувствовали себя лучше." if caster==target
      caster.send "Вы произнесли #{Color.light_blue("заклинание ицеления")}.#{af}"
      
      
      caster.room.creatures.each{|cr| cr.send "#{caster.name} прознес #{Color.light_blue("заклинание ицеления")}."+("\nВы почувствовали себя лучше." if cr == target).to_s if cr!=caster }
      target.save
      caster.save
      
    else
      caster.send "У вас не хватает маны для произнесения #{Color.light_blue("заклинания ицеления")}."
    end
  end
  
end