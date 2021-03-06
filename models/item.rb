class Item < MObject

  POSITIONS = [:lie, :taken, :equiped]
  TYPES = ["armor", "weapon", "common", "container"]
  EQUIPMENT_TYPES = {
                  "head"      => ["on head",       1],
                  "neck"      => ["on the neck",          3],
                  "hair"      => ["in hair",       1],
                  "eyes"      => ["eyewear", 1],
                  "ears"      => ["earings",          2],
                  "nose"      => ["in the nose",          2],

                  "shoulders" => ["over the shoulders",     2 ],
                  "arms"      => ["arms",      1 ],
                  "hands"     => ["hands",     1 ],
                  "ring"      => ["finger",     20],
                  "wrist"     => ["wrists",  4 ],
                  "forearm"   => ["forearm", 2 ],

                  "body"      => ["body",  1],
                  "waist"     => ["waist", 2],

                  "legs"      => ["на ногах",   1],
                  "boots"     => ["как обувь",      1],
                  "knees"     => ["на коленях", 1],

                  "left"      => ["в левой руке",  1],
                  "right"     => ["в правой руке", 1],
                  "both"      => ["в обеих руках", 1]
                }
  DAMAGE_TYPES = {
                  "hand" => ["hit", "hit"],
                  "cut"  => ["cut", "cut"],
                  "chop" => ["slashed", "slash"]
                  }

  attr_accessor :position, :owner, :equiped_on

  def initialize(hash)
    super(hash)
    @room = hash[:room]
    self.position = hash[:position]
    self.owner = hash[:owner]
    self.equiped_on = false
    @type = hash[:type]||"common"
    @equip = hash[:equip] || false
    @damage_type = hash[:damage_type] || "hand"
  end

  def equip;@equip;end
  def damage_type;@damage_type;end
  def room
    Room.find(@room)
  end

  def room=(ro)
    if ro.nil?
      @room = nil
    else
      @room = ro.id
    end
  end

  def f_position
    "lying here" if position==:lie
  end

  def Item.find(query)
    query[:room]  ||= false
    query[:owner] ||= false
    query[:name]  ||= false

    items = DataBase.items.collect{ |id, item|
      item if (!query[:name] || !item.aliases.collect{|nf| 1 if nf.close_to(query[:name])}.compact.empty?  ) &&
              (!query[:room] || query[:room]==item.room) &&
              (!query[:owner] || query[:owner]==item.owner) &&
              (!query[:position] || query[:position]==item.position)
    }.compact
    if items.empty?
      false
    else
      items
    end
  end

  def view
    "Just #{self.name}:\n#{self.inspect}."
  end

  def save
    DataBase.save_item(self)
  end

  def drop
    self.room = owner.room
    self.owner = nil
    self.position = :lie
    self.save
  end

  def take(cr)
    self.room = nil
    self.owner = cr
    self.position = :taken
    self.save
  end

  def use
    self.position = :equiped
    self.equiped_on = @equip
    self.save
  end

  def remove
    self.position = :taken
    self.equiped_on = false
    self.save
  end

  def hash4save
    {}
  end
  def equipable?;@equip!=false;end
end
