#!/usr/bin/env ruby

# command:
#   $ Tracker.pl 30 "I did stuff"
#   $ Tracker.pl 1h "I did twice as much stuff"
#
# format:
#   - First arg is how much time spent
#   - Second arg is a description

require 'trollop'
require './tracker_util'

# place where data is stored
datadir = "#{ENV['HOME']}/Documents/Tracker/"
%x[mkdir -p #{datadir}]

# define command line options
opts = Trollop::options do
  opt :report, "Reporting mode", :short => '-l'
  opt :edit, "Edit mode"
  opt :date, "The date", :type => String
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
      STDERR.puts $!
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
    puts "Hours logged until #{newTimeString}. (since #{TrackerUtil::to12HourTime(startTime)}). "
    
    # if we're reporting for today, print the current time
    puts "Currently #{TrackerUtil::to12HourTime(TrackerUtil::currentTimeFormatted())}." unless opts[:date]
  else
    if opts[:date]
      STDERR.puts "No time log for #{fdate}. Track some time first."
    else
      STDERR.puts "No time log for today. Track some time first.\n"
    end
  end
end
__END__
elsif ($MODE eq 'edit') {
    if (-e $filename) {
        if (exists $ENV{'EDITOR'}) {
            exec("$ENV{'EDITOR'} $filename");
        }
        else {
            `open $filename`;
        }
        exit(0);
    }
    else {
        die "Couldn't open $filename: $!";
    }
}
elsif ($MODE eq 'insert') {
    if ($date_arg) {
        print "WARNING: Adding time to a day other than today is not recommended.\n";
        print "Continue? (y/n) ";
        $input = <STDIN>;
        if (!($input =~ /^y(es)?/i)) {
            print STDERR "Timelog update cancelled.\n";
            exit(1);
        }
    }
    
    # process arguments
    my $minutes = processTimeArgument($ARGV[0]);
    my $message = join(" ", @ARGV[1..@ARGV-1]);
    
    # open the output file
    if (!-e $filename) {
        open TIMELOG, ">> $filename" or die "Couldn't open $filename: $!";
        my $currentTimeInMinutes = timeToMinutes(currentTimeFormatted());
        my $startTime = minutesToTime(nearest15Minutes($currentTimeInMinutes - $minutes));
        print TIMELOG "$fdate $startTime\n";
    }
    else {
        open TIMELOG, ">> $filename" or die "Couldn't open $filename: $!";
    }
    
    # print the logged time
    print TIMELOG "$minutes: $message\n";
}
else {
    die("Couldn't determine the correct mode (I was given '$MODE'):$!");
}







# expects a single argument - the time argument in the format ##m or ##h
# if argument has no m/h qualifier, assume m
# returns a number of minutes
sub processTimeArgument
{
    if (@_ == 1) {
        my $minutes;
        if ($_[0] =~ /^(\d*\.?\d+)((m|min|minute|minutes)|(h|hr|hour|hours))?$/i) {
            my $time = $1, $modifier = $2;
            if ($modifier =~ /h.*/) {
                $minutes = $time * 60;
            }
            else {
                $minutes = $time;
            }
            
            # check enough time has been logged
            if ($minutes < 15) {
                print STDERR "You must log at least 15 minutes.\n";
                exit(1);
            }
            
            return nearest15Minutes(nearestInt($minutes));
        }
        else {
            print STDERR "Incorrectly formatted argument.\n";
            exit(1);
        }
    }
}

# expects a number of minutes
# if less than 60 returns the number with an "m"
# otherwise converts to hours and adds an "h"
sub timeString
{
    return $_[0] >= 60 ? $_[0]/60 . "h" : $_[0] . "m";
}

# expects a hash of tasks mapped to time spent, and a sub-report name
#   (e.g., work, personal)
# prints a formatted sub-report
# returns the total hours worked
sub printSubReport
{
    my %report = %{$_[0]};
    my $name = $_[1], my $total;
    if (%report > 0) {
        foreach (values(%report)) { $total += $_; }
        print "# $name time (".timeString($total).")\n";
        while (($task, $timeSpent) = each(%report)) {
            print "=> " . timeString($timeSpent) . ": $task\n";
        }
    }
    return $total;
}

sub newTimeWithMinutes
{
    my $len = @_;
    if ($len == 2) {
        my @startTime = split(":", $_[0]);
        my $startMinutes = $startTime[0] * 60 + $startTime[1];
        my $endMinutes = $startMinutes + $_[1];
        my $newHours = int($endMinutes / 60);
        my $newMinutes = $endMinutes % 60;
        my $newFormatted = sprintf("%d:%02d", $newHours, $newMinutes);
        return $newFormatted;
    }
}

# expects a time string formatted HH24:MM
sub timeToMinutes
{
    my $len = @_;
    if ($len == 1) {
        my @theTime = split(":", $_[0]);
        my $minutes = $theTime[0] * 60 + $theTime[1];
        return $minutes;
    }
}

# expects an integer
sub minutesToTime
{
    my $len = @_;
    if ($len == 1) {
        my $totalMinutes = $_[0];
        my $minutes = sprintf("%02d", $totalMinutes % 60);
        my $hours = int($totalMinutes / 60);
        return "$hours:$minutes";
    }
}

sub currentTimeFormatted
{
    (my $currentMinutes, my $currentHours) = (localtime)[1,2];
    return $currentHours . ":" . sprintf("%02d", $currentMinutes);
}

# expects an integer which is the amount of minutes logged
sub startTimeInMinutes
{
    my $currentTimeInMinutes = timeToMinutes(currentTimeFormatted());
    my $rounded = nearest15Minutes($currentTimeInMinutes);
    return $rounded - $_[0];
}

sub nearestInt
{
    my $integerPart = int($_[0]);
    my $decimalPart = $_[0] - $integerPart;
    return $decimalPart >= 0.5 ? $integerPart + 1 : $integerPart;
}

# expects an integer
sub nearest15Minutes
{
    my $len = @_;
    if ($len == 1) {
        my $remainder = $_[0] % 15;
        my $basetime = $_[0] - $remainder;
        if ($remainder > 7) {
            return $basetime + 15;
        }
        else {
            return $basetime;
        }
    }
}
