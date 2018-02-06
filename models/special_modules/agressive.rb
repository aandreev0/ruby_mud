module Agressive
  def on_say(who, what)
    say "Молчать!!!"
    attack(who)
  end
end