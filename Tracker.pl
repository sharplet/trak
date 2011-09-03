#!/usr/bin/env perl

# command:
#   $ Tracker.pl 30 "I did stuff"
#   $ Tracker.pl 1h "I did twice as much stuff"
#
# format:
#   - First arg is how much time spent
#   - Second arg is a description

# place where data is stored
$datadir = "$ENV{'HOME'}/Documents/Tracker/";
`mkdir -p $datadir`;

# get today's date, formatted
($day, $month, $year) = (localtime)[3,4,5];
$fdate = sprintf("%04d-%02d-%02d", $year + 1900, $month + 1, $day);

# set the output file name
$filename = $datadir.$fdate."-time-log.txt";

if ($ARGV[0] eq "-r" || $ARGV[0] eq "-l" || @ARGV == 0) {
    if (-e $filename) {
        open REPORTFILE, "< $filename" or die "Couldn't open $filename: $!";
        @file = <REPORTFILE>;
        $end = @file;
        $personal = 0, $total = 0;
        @firstLine = split(/\ /, $file[0]);
        my $startTime = $firstLine[1];
        print "# Today's logged work\n";
        foreach $line (@file[1..$end-1]) {
            chomp($line);
            $line =~ /^(\d+)\:\s+(.+)$/;
            $minutes = $1;
            $text = $2;
            if (!($text =~ /personal|uni|lunch|home/)) {
                $total += $minutes;
            }
            else {
                $personal += $minutes;
            }
            print "=> ".$minutes."m: $text\n";
        }
        if ($total > 0) { print "Work time = " . $total/60 . "h\n"; }
        if ($personal > 0) { print "Personal time = " . $personal/60 . "h\n"; }
        $newTimeString = to12HourTime(newTimeWithMinutes($startTime, $total + $personal));
        print "Hours logged until ".$newTimeString." (since ".to12HourTime($startTime).").\n";
    }
    else {
        print STDERR "No time log for today. Track some time first.\n";
    }
}
else {
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







# expects a single argument - the time argument in the format ##m or ##h
# if argument has no m/h qualifier, assume m
# returns a number of minutes
sub processTimeArgument
{
    if (@_ == 1) {
        my $minutes;
        if ($_[0] =~ /^(\d*\.?\d+)([mh])?$/i) {
            if ($2 ne "h") {
                $minutes = $1;
            }
            else {
                my $hours = $1;
                $minutes = $hours * 60;
            }
            
            # check enough time has been logged
            if ($minutes < 15) {
                print STDERR "You must log at least 15 minutes.\n";
                exit(1);
            }
            
            return nearest15Minutes(nearestInt($minutes));
        }
        else {
            die "Incorrectly formatted argument";
            exit(1);
        }
    }
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

sub to12HourTime
{
    my @time = split(":", $_[0]);
    my $suffix;
    if ($time[0] >= 12) {
        if ($time[0] > 12) { $time[0] -= 12; }
        $suffix = "PM";
    }
    else {
        if ($time[0] == 0) {
            $time[0] = 12;
        }
        $suffix = "AM";
    }
    chomp($time[1]);
    sprintf("%02d", $time[1]);
    return join(":", @time)." $suffix";
}
