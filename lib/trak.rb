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

require "trak/util"
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
  debugger if $g_opts[:debug]
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
      STDERR.puts "#{__FILE__}: #{$!}"
      exit 1
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
    
    workTotal = TrackerUtil::printSubReport(work, "Work")
    personalTotal = TrackerUtil::printSubReport(personal, "Personal")
    
    newTimeString = TrackerUtil::to12HourTime(TrackerUtil::newTimeWithMinutes(startTime, workTotal + personalTotal))
    puts "Hours logged until #{newTimeString} (since #{TrackerUtil::to12HourTime(startTime)}). "
    
    # if we're reporting for today, print the current time
    puts "Currently #{TrackerUtil::to12HourTime(Time.now.strftime(TrackerUtil::TIME_FORMAT_24HOUR))}." unless opts[:date]
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
    STDERR.puts "#{__FILE__}: #{filename} does not exist or unable to open."
    exit 1
  end

elsif MODE == 'insert'
  if opts[:date]
    puts "WARNING: Adding time to a day other than today is not recommended."
    print "Continue? (y/n) "
    input = STDIN.readline.chomp
    unless input =~ /^y(es)?/i
        STDERR.puts "Timelog update cancelled."
        exit 1
    end
  end
  
  # process arguments
  debug
  minutes = TrackerUtil::processTimeArgument ARGV.shift
  message = ARGV.join(" ")
  
  # open the output file
  first_time = !File.exist?(filename)
  # debug
  begin
    File.open filename, 'a', :autoclose => true do |file|
      if first_time
        debug
        currentTimeInMinutes = Time.now.to_minutes
        startTime = TrackerUtil::minutesToTime((currentTimeInMinutes - minutes).round_to_nearest 15)
        file.puts "#{fdate} #{startTime}"
      end
      file.puts "#{minutes}: #{message}"
    end
  rescue
    STDERR.puts "Couldn't open #{filename}: #{$!}"
    exit 1
  end

else
    STDERR.puts "Couldn't determine the correct mode (I was given '#{MODE}'): #{$!}"
    exit 1
end
