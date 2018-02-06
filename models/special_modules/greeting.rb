module Greeting

  def Greeting.extend_object(creature)
    creature.append_filter(:after_say, Proc.new{|who, what|
      creature.say "Привет, #{who.name}. Не желаешь ли чего-нибудь купить?" if what=~/^привет/
    })
  end
end