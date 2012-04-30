#!/usr/bin/env ruby

# command:
#   $ trak 30 work on trak
#   $ trak 1h work really hard on trak
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
  if File.exist? filename
    # open the file and get it as an array
    begin
      file = File.open(filename).readlines.map &:chomp
    rescue
      Exit::exit_err "#{__FILE__}: #{$!}"
    end
    
    # The keys for each hash are the titles of the various tasks logged.
    # The values are the total time spent on the task.
    work = {}
    personal = {}
    
    # find the start time for the day we're reporting on
    startTime = file.first.split[1]
    
    # process each line of the file
    file[1..file.size].each do |line|
      minutes, text = line.split(': ')
      unless text =~ /personal|uni|lunch|home/
        work[text] = 0 unless work.include? text
        work[text] += minutes.to_i
      else
        personal[text] = 0 unless personal.include? text
        personal[text] += minutes.to_i
      end
    end
    
    # print the report
    if opts[:date]
        puts "# Logged work for #{fdate}"
    else
        puts "# Today's logged work"
    end
    
    workTotal = Trak::printSubReport(work, "Work")
    personalTotal = Trak::printSubReport(personal, "Personal")
    
    newTimeString = Trak::to12HourTime(Trak::newTimeWithMinutes(startTime, workTotal + personalTotal))
    puts "Hours logged until #{newTimeString} (since #{Trak::to12HourTime(startTime)}). "
    
    # if we're reporting for today, print the current time
    puts "Currently #{Trak::to12HourTime(Time.now.strftime(Trak::TIME_FORMAT_24HOUR))}." unless opts[:date]
  else
    if opts[:date]
      STDERR.puts "No time log for #{fdate}. Track some time first."
    else
      STDERR.puts "No time log for today. Track some time first.\n"
    end
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
