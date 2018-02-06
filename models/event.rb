WEATHER = [""]

class Event
  def Event.each_tick
    Thread.new do
      loop do
        send_to_all "Время сервера: #{Time.now.strftime("%H:%M:%S")}."
        
        Player.find(:online).each do |player|
          player.rest
        end
        
        sleep 60
      end
    end
  end
  
  def Event.fight_ticks
    #Thread.do
   # 
   # end
  end
end