list = ["agressive", "greeting", "assistance", "login"]
list.each do |mod|
  require "./models/special_modules/#{mod}.rb"
end
