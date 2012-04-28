#!/usr/bin/env ruby

# command:
#   $ Tracker.pl 30 "I did stuff"
#   $ Tracker.pl 1h "I did twice as much stuff"
#
# format:
#   - First arg is how much time spent
#   - Second arg is a description

require 'trollop'
require 'debugger'

require 'trak/trak'
require 'trak/exit'
require 'trak/core_ext/time'

# place where data is stored
datadir = "#{ENV['HOME']}/Documents/Tracker/"
%x[mkdir -p #{datadir}]

# define command line options
opts = Trollop::options do
  opt :report, "Reporting mode", :short => "-l"
  opt :edit, "Edit mode"
  opt :date, "The date", :type => String, :short => "-d"
  opt :debug, "Debugging mode", :short => "-i"
end

$g_opts = opts
def debug(steps = 1)
  debugger(steps) if $g_opts[:debug]
end

# all valid options have been processed, so figure out which mode
# we're in...
#
# if we found a -r or -l option, ignore everything else
if opts[:report]
  MODE = 'report'
# now check if the user wants edit mode
elsif opts[:edit]
  MODE = 'edit'
# if there are still unprocessed args (that didn't look like switches),
# we're in insert mode
elsif ARGV.length > 0
  MODE = 'insert'
# if all else fails, there were probably no args to begin with, so we're
# in report mode
else
  MODE = 'report'
end

today = Time.now.strftime '%F'

# did the user supply a date argument that isn't today?
if opts[:date] && opts[:date] != today
  fdate = opts[:date]
# otherwise use today's date, formatted, and set date_arg to be false
else
  fdate = today
  opts[:date] = nil
end

# set the output file name
filename = "#{datadir}#{fdate}-time-log.txt"

if MODE == 'report'
  Trak::log_for fdate do |l|
    l.report
  end

elsif MODE == 'edit'
  if File.exist? filename
    if ENV['EDITOR']
      exec "#{ENV['EDITOR']} #{filename}"
    else
      exec "open", filename
    end
    exit
  else
    Exit::exit_err "#{__FILE__}: #{filename} does not exist or unable to open."
  end

elsif MODE == 'insert'
  if opts[:date]
    puts "WARNING: Adding time to a day other than today is not recommended."
    print "Continue? (y/n) "
    input = STDIN.readline.chomp
    unless input =~ /^y(es)?/i
        Exit::exit_err "Timelog update cancelled."
    end
  end
  
  # process arguments
  debug
  minutes = Trak::processTimeArgument ARGV.shift
  message = ARGV.join(" ")
  
  # open the output file
  first_time = !File.exist?(filename)
  # debug
  begin
    File.open filename, 'a', :autoclose => true do |file|
      if first_time
        debug
        currentTimeInMinutes = Time.now.to_minutes
        startTime = Trak::minutesToTime((currentTimeInMinutes - minutes).round_to_nearest 15)
        file.puts "#{fdate} #{startTime}"
      end
      file.puts "#{minutes}: #{message}"
    end
  rescue
    Exit::exit_err "Couldn't open #{filename}: #{$!}"
  end

else
    Exit::exit_err "Couldn't determine the correct mode (I was given '#{MODE}'): #{$!}"
end
