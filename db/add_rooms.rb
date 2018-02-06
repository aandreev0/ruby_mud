require 'yaml'
File.open( 'new_rooms.yaml', 'w' ) do |out|
  
  rooms = [{:name => "name",
            :title => "title",
            :descritpion => "description",
            :exits => {"north"=>2, "south"=>2},
            :monsters => [{1 => {}}, { 1 => {}}]
          },
          {:name => "name",
            :title => "title",
            :descritpion => "description",
            :exits => {"north"=>2, "south"=>2},
            :monsters => [{1 => {}}, { 1 => {}}]
          }]
  
  YAML.dump(rooms, out)
end