class Monster < Creature

  def initialize(hash)
    super(hash)
    @speed = hash[:speed]

    set_round_move_filter

  end
  def speed;@speed;end
  def online?;true;end

  def fight_log;"";end
  def send_fight_log;true;end

  def on_attack(creature)
    say "Сука, #{creature.name}!"
    stand_up
  end

  def save
    unless position == :died
      if self.health<=0
        self.position = :died
        self.target = nil
        self.room.creatures.each{|cr|
          cr.after_death(self) unless cr == self
        }
      end
    end
    DataBase.save_monster self
  end

  def set_round_move_filter
    self.append_filter(:after_nonfight_round, Proc.new { ||
      self.move self.room.random_exit if rand(10)+1 <= self.speed
    })
  end

  def hash4save
    {
    :room         => room.id,
    :health       => self.health,
    :max_health   => self.max_health,
    :moves        => self.moves,
    :max_moves    => self.max_moves,
    :mana         => self.mana,
    :max_mana     => self.max_mana,
    :affects      => affects,
    :position     => position,
    :gender       => gender.to_s,
    :name_forms   => name_forms.collect{|n| n.to_s},
    :description  => description.to_s,
    :race         => race.to_i,
    :side         => side.to_i,
    :stats        => stats
    }
  end

end
