begin
  require 'Win32/Console/ANSI' if PLATFORM =~ /win32/
rescue LoadError
  raise 'You must gem install win32console to use color on Windows'
end

def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

def red(text); colorize(text, "31"); end
def green(text); colorize(text, "32"); end
def white(text); colorize(text, "1;37;40"); end
def dark_blue(text); colorize(text, "0;36;40");end
def yellow(text); colorize(text, "1;33;40");end