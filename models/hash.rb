class Hash
  def +(h)
    out = {}
    h.each{|k,v| out[k]=v}
    self.each{|k,v| out[k]=v}
    out
  end
  
end

class String
  def close_to(str)
    s = self.downcase.to_s
    st = str.downcase.to_s
    true if s=~/^#{st}/ || st=~/^#{s}/
  end
end