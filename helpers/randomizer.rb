module Randomizer
  def Randomizer.roll(dice)
    n, s = dice.split(/d/)
    res = 0
    n.to_i.times { res += 1+rand(s.to_i.floor) }
    return res
  end
end