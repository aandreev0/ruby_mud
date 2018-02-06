class Player < Creature
  def Player.login(inp, sock)
    $log.info inp
    inp = inp.to_s
    screen = "\n"+
             "      #{Color.light_blue(".........................................")}\n"+
             "      #{Color.white(".")}                                       #{Color.white(".")}\n"+
             "      #{Color.light_blue(".")}             #{Color.light_green("Привет! Привет!")}           #{Color.light_blue(".")}\n"+
             "      #{Color.white(".")}   Это #{Color.light_yellow("MULC: Multi User Lands&Cities")}   #{Color.white(".")}\n"+
             "      #{Color.light_blue(".")}                                       #{Color.light_blue(".")}\n"+
             "      #{Color.white(".")}          ^     ======      ^          #{Color.white(".")}\n"+
             "      #{Color.light_blue(".")}---#---#-/|\\-#--|++++|---#-/|\\-#---#---#{Color.light_blue(".")}\n"+
             "      #{Color.white(".")}   |   | /|\\ |  |++++|   | /|\\ |   |   #{Color.white(".")}\n"+
             "      #{Color.light_blue(".")}___|___|__|__|__|++++|___|__|__|___|___#{Color.light_blue(".")}\n"+
             "      #{Color.white(".........................................")}\n\n"+
             "Введите имя персонажа или \"new\" для создания нового:"

    out, sock.login_step = case sock.login_step
      when nil # нет персонажа, ищем старого или делаем нового
        if inp == "new"
          ["Введите имя нового персонажа:", :new_player_name]
        elsif inp.length>0 && player = Player.find({:name => inp})
          sock.player_id = player[0].id
          ["Введите пароль:", :enter_old_player_password]
        elsif inp.length>0 && !player
          [screen+"\n"+Color.light_red("Персонаж \"#{inp}\" не найден!\n"), nil]
        else
          [screen, nil]
        end

      ### NEW PLAYER ###
      when :new_player_name
        if Player.find({:name=>inp})
          ["Try another name:", :new_player_name]
        elsif inp.gsub(/[a-zA-z]/u, '')!=""
          ["Please use only a-zA-z:", :new_player_name]
        else
          sock.login_data[:player_name] = inp
          ["Enter gender (#{REG_GENDERS.join("/")}):", :new_player_gender]
        end



      when :new_player_gender
        if REG_GENDERS.include?(inp)
          sock.login_data[:player_gender] = REG_GENDERS.index(inp)
          list = "\n"
          Creature::SIDES.each_index{|i| list << "  #{i}) #{Creature::SIDES[i]}\n" }
          ["Choose side:#{list}", :new_player_side]
        else
          ["Enter gender (#{REG_GENDERS.join("/")}):", :new_player_gender]
        end

      when :new_player_side
        i = inp.to_s.to_i
        if Creature::SIDES[i]
          sock.login_data[:player_side] = i
          races = Creature::RACES.collect{|r| r if r[1]==2 || r[1]==sock.login_data[:player_side] }.compact
          list = "\n"
          races.each_index{|i| list<< "  #{i}) #{races[i][0]}\n" }
          ["Выберите расу персонажа:#{list}", :new_player_race]
        else
          list = "\n"
          Creature::SIDES.each_index{|i| list << "  #{i}) #{Creature::SIDES[i]}\n" }
          ["Pick a side:#{list}", :new_player_side]
        end

      when :new_player_race
        i = inp.to_s.to_i
        races = Creature::RACES.collect{|r| r if r[1]==2 || r[1]==sock.login_data[:player_side] }.compact
        if (races[i])
          sock.login_data[:player_race] = Creature::RACES.index(races[i])
          ["Emter password:", :new_player_password]
        else
          list = "\n"
          races.each_index{|i| list<< "  #{i}) #{races[i][0]}\n" }
          ["Chose race:#{list}", :new_player_race]
        end

      when :new_player_password
        if inp.gsub(/\s/,'')!=""

          sock.login_data[:player_password] = inp

          player = Player.new({:name     => sock.login_data[:player_name],
                               :password => sock.login_data[:player_password],
                               :gender   => sock.login_data[:player_gender],
                               :race     => sock.login_data[:player_race],
                               :side     => sock.login_data[:player_side]})
          $log.info player
          player.socket = sock
          sock.player_id = player.id
          player.logged_in = true
          player.save
          DataBase.dump
          ["Character \"#{player.name}\" is created!", :logged]
        end

      ### OLD PLAYER ###
      when :enter_old_player_password
        unless sock.player.online?
          if sock.player.password == inp
            sock.player.logged_in = true
            sock.player.socket = sock
            sock.player.save
            ["Вы зашли в игру.", :logged]
          else
            ["Wrong password!", :kick]
          end
        else
          ["This character already logged-in!", :kick]
        end
    end
    sock.put out
    sock
  end


end
