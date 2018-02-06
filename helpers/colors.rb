#
# http://kpumuk.info/ruby-on-rails/colorizing-console-ruby-script-output/lang/ru/
#

begin
  require 'Win32/Console/ANSI' if RUBY_PLATFORM =~ /win32/
rescue LoadError
  raise 'You must gem install win32console to use color on Windows'
end

module Color

  def Color.colorize(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end

  def Color.light_red(text); colorize(text, "1;31;40"); end
  def Color.dark_red(text); colorize(text, "0;31;40"); end

  def Color.light_green(text); colorize(text, "1;32;40"); end
  def Color.dark_green(text); colorize(text, "0;32;40"); end

  def Color.white(text); colorize(text, "1;37;40"); end
  def Color.gray(text); colorize(text, "0;37;40"); end

  def Color.light_blue(text); colorize(text, "0;36;40");end
  def Color.dark_blue(text); colorize(text, "0;34;40");end

  def Color.light_yellow(text); colorize(text, "1;33;40");end
  def Color.dark_yellow(text); colorize(text, "0;33;40");end

  def Color.number(n, max, str)
    if n>max*0.7
      Color.dark_green(str)
    elsif n>max*0.3
      Color.dark_yellow(str)
    else
      Color.dark_red(str)
    end
  end
end
