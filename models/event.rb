class Event
  ROUND = 2
  TICK = 60
  PULSE = 0.1

  def Event.each_round
    
    Thread.new do
      begin
        loop do
          DataBase.fighters.each{|cr|
            cr.in_round
          }
          DataBase.fighters.each{|cr|
            cr.after_round
          }
          DataBase.rooms.each{|id, room|
            room.creatures.each{|cr| cr.after_nonfight_round }
          }
          sleep ROUND
        end
      rescue
       $log.info "event.rb err: "+$!
      end
    end
  end
  
  def Event.each_pulse
  end
  
  def Event.each_tick
    Thread.new do
      begin
        loop do
          sleep TICK
          $log.info " -- tick -->"
          DataBase.rooms.each{|id, room|
              room.creatures.each{|cr| cr.on_tick }
          }
          DataBase.dump
        end
      rescue
        $log.info "event.rb err: "+$!
      end
    end
  end
end
