module Assistance
  def Assistance.extend_object(creature)
    
    creature.append_filter(:after_nonfight_round, Proc.new do ||
      unless creature.fighting?
        creature.room.monsters.each{|cr|
          if cr.fighting?
            creature.say "Я спасу тебя, #{cr.name}!"
            creature.attack cr.target
            break
          end
        }
      end
    end)
    
  end
end