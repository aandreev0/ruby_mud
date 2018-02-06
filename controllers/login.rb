def login(*args)
  inp, sock = args
  hat = <<HEREDOC
  # # # # # # # # # # # # # #
  #         BioMUL.         #
  #                         #
  #   multiusers lections   #
  #                         #
  # # # # # # # # # # # # # #
HEREDOC
  
  in_game = <<HD
  Добро пожаловать!
  Если вам понадобится помощь, используйте команду "справка".
  Основные команды: СМОТРЕТЬ, СЕВЕР, ВОСТОК, ЮГ, ЗАПАД
HD
  
  player = nil
  
  # LOGIN STEPS:
  #  1 ask for new char or an old one; sock.login_step=:new_char||:old_char
  #  2 char login:
  #  2.1 :new_char => ask name, validate and validate uniquiness
  #  2.1.1 
  #  2.2 :old_char => ask for password and validate
  #  2.2.1 true  => #login.step=:logged_in
  #  2.2.2 false => #login.step=:exit
  
  unless inp==""
  
    result = case sock.login_step
      when nil
        ["#{hat}\nУ вас уже есть персонаж? (да/нет)", :new_or_old]
        
      when :new_or_old
        if "да"=~/^#{inp}/
          ["Отлично! Введите тогда его имя, пожалуйста:", :old_char]
        elsif "нет"=~/^#{inp}/
          ["Тогда создадим нового. Как его будут звать? (только кириллица, без пробелов)", :new_char]
        else
          ["Так у вас уже есть персонаж или нет? (да/нет)", :new_or_old]
        end
        
      when :new_char
        if inp=~/[а-яА-Я]/
          sock.char_name = inp
          ["А теперь придумайте его пароль:", :new_char_password]
        else
          ["Только кириллица и никаких пробелов!", :new_char]
        end
        
      when :new_char_password
        player = Player.new({:name=> sock.char_name, :socket=>sock, :password=>inp})
        player.save
        inp = ""
        [in_game,:logged_in]
        
      when :old_char
        if Player.find({:name=>inp})
          sock.char_name = inp
          ['Введите его пароль:', :entering_old_char_password]
        else
          @@log.info "Char not found: #{inp}"
          ['Не нашел такого персонажа, извините! Попробуем снова?', :old_char]
        end
        
      when :entering_old_char_password
        player = Player.find({:name=>sock.char_name})
        if player.password == inp
          inp = ""
          player.socket = sock
          player.save
          [in_game,:logged_in]
        else
          #@@log.info "Bad password: #{inp}!=#{player.password}"
          ['Неправильный пароль!', :entering_old_char_password]
        end
      when :logged_in
        player = Player.find({:name=>sock.char_name})
        [nil, :logged_in]
    end
      
    send_to_socket(result[0], sock) unless result[0].nil?
    sock.login_step = result[1]
    return result[1], player
  
  else
    send_to_socket("Написали бы чего-нибудь!", sock)
    return sock.login_step, nil
  end
  
end