Room::DIRECTIONS.each do |dir|
  eval("def go_#{dir}(*args)
    player, t = args
    if player.move(\"#{dir}\")
      command_look(player)
    end
  end")
end