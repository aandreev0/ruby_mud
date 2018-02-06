class Zone < MObject
  
  attr_accessor :rooms
  
  def initialize(rooms_arr)
    rooms_arr.each do |r|
      self.rooms<< Room.new(r)
    end
  end
  
  def reboot
  end
  
end