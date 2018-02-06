class MObject

  attr_accessor :procedures, :id
  def initialize(hash)
    self.procedures = {}

    if sp_mods = hash[:special_module]
      sp_mods.split(/\s/).each{|mod|  self.extend eval("#{mod}")}
    end
    self.id = hash[:id] if hash[:id]
    @gender = hash[:gender].to_i || 2
    @name_forms = hash[:name_forms].collect{|nf| nf.chars}
    @long_name = hash[:long_name] || nil
    @description = (hash[:description] ? hash[:description].chars : @name_forms[0])

    #@aliases = (hash[:aliases] || @name_forms[0]).split(/\s/).collect{|nf| nf if nf.length>2 }.compact
    @aliases = hash[:aliases]
  end

  def name;@name_forms[0];end
  def long_name;@long_name;end
  def aliases;@aliases;end

  def name_forms;@name_forms;end
  def f_names_forms;name_forms.join("/");end
  def description;@description;end

  def method_missing(meth, *args)
    if procedures[meth]
      procedures[meth].each do |proc|
        proc.call(args)
      end
    else
      #$log.info "[Err] MethodMissing on #{self}: #{meth.id2name}(#{args})"
    end
  end

  def append_filter(filt, proc)
    self.procedures[filt] ||= []
    self.procedures[filt] << proc
  end

  def save;end
end
