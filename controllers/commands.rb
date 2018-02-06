module Commands

  LIST = {
    "look" => "look",
    "tell" => "tell",
    "say" => "say",
    "save" => "save_base",
    "north" => "go_north",
    "south" => "go_south",
    "west" => "go_west",
    "east" => "go_east",
    "down" => "go_down",
    "up" => "go_up",
    "who" => "who",
    "EXIT" => "exit",
    "scan" => "scan",
    "attack" => "attack",
    "flee" => "flee",
    "sit" => "sit_down",
    "stand" => "stand_up",
    "sleep" => "sleep",
    "wake" => "wake_up",

    "inventory" => "inventory",
    "equipment" => "equipment",
    "take" => "take",
    "drop" => "drop",
    "use" => "use",
    "remove" => "remove",

    "score" => "scores",
    "cast" => "cast",
    "help" => 'help'
  }

  def Commands.scan(player, *a)
    player.scan
  end

  def Commands.tell(creature, *args)
    to, msg = args[0].split(/\s/, 2)

    if (pl = Player.find({:name => to})) && pl.online? && pl.visible_for(creature)
      if pl == creature
        creature.send "С собой поговорите?"
        return false
      end
      creature.tell(pl, msg)
    else
      creature.send "Никого с именем #{to} здесь нет."
    end

  end

  def Commands.say(creature, *args)
    str = args
    creature.say str[0]
  end

  def Commands.look(creature, *on)
    creature.look(on[0])
  end

  def Commands.save_base(player, *args)
    DataBase.dump
    player.send("DB dumped")
  end

  def Commands.attack(who, target)
    if tar = who.find_by_name_and_room(target, who.room)
      who.attack(tar.first)
    else
      who.send "Вы не видите здесь #{target}."
    end
  end

  def Commands.flee(player, *args)
    player.flee
  end

  Room::EXITS.each do |k, ex|
    dir = k
    eval("def Commands.go_#{dir}(player, *args)
      if player.move(\"#{dir}\")
        Commands.look(player)
      end
    end")
  end

  def Commands.who(player, targ)
    if targ == "все"
      out = Color.white("Все игроки\n")
      pls = Player.find(:all).collect{|pl| " #{pl.titled_name}"}
    else
      out = Color.white("Сейчас в игре\n")
      pls = Player.find(:online).collect{|pl| "  #{pl.titled_name}" if pl.visible_for(player)}.compact
    end
    out << pls.join("\n")+"\nВсего: #{pls.length}"
    player.send out
  end

  def Commands.sit_down(player, *a)
    player.sit_down
  end

  def Commands.stand_up(player, *a)
    player.stand_up
  end

  def Commands.sleep(player, *a)
    player.go_to_sleep
  end

  def Commands.wake_up(player, *a)
    player.wake_up
  end

  def Commands.exit(player, *a)
    player.send "Выход..."
    player.exit
  end

  def Commands.inventory(player, *args)
    player.inventory_view
  end

  def Commands.equipment(player, *args)
    player.equipment_view
  end

  def Commands.take(player, targ)
    if targ && item = Item.find({:room => player.room, :name=>targ})
      player.take(item[0])
    else
      player.send "Взять что?"
    end
  end

  def Commands.drop(player, targ)
    if targ && items = Item.find({:owner => player, :position=>:taken, :name=>targ})
      player.drop(items[0])
    else
      player.send "Бросить что?"
    end
  end

  def Commands.use(player, targ)
    if targ && items = Item.find({:owner => player, :position=>:taken, :name=>targ})
      player.use(items[0])
    else
      player.send "Использовать что?"
    end
  end

  def Commands.remove(player, targ)
    if targ && items = Item.find({:owner => player, :position=>:equiped, :name=>targ})
      player.remove(items[0])
    else
      player.send "Снять что?"
    end
  end

  def Commands.scores(player, *a)
    player.scores
  end

  def Commands.cast(caster, args)
    spell, target = args.split(/\s/)
    if caster.round_busy == 0
      if spell
        if (!target && cr = [nil]) || cr = caster.find_by_name_and_room(target, caster.room)
          found = false
          sp = nil
          Magic::SPELLS.each do |word, meth|
            if word.close_to(spell)
              sp = meth
              found = true
              break
            end
          end

          if found
            eval("Spell.#{sp}(caster, cr[0])")
          else
            caster.send "Вы не знаете заклинания #{spell}"
          end
        else
          caster.send "Не вижу тут #{target}"
        end
      else
        caster.send "Чего колдовать?"
      end
    else
      caster.send "Вы еще не отдышались!"
    end

  end

  def Commands.help(player, target)
    player.send LIST.to_s
  end


end
