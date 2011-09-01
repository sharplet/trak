#!/usr/bin/env perl

# command:
#   $ Tracker.pl 30 "I did stuff"
#   $ Tracker.pl 1h "I did twice as much stuff"
#
# format:
#   - First arg is how much time spent
#   - Second arg is a description

# place where data is stored
$datadir = "~/Documents/Tracker/";
`mkdir -p $datadir`;

# get today's date, formatted
($day, $month, $year) = (localtime)[3,4,5];
$fdate = sprintf("%04d-%02d-%02d", $year + 1900, $month + 1, $day);

# set the output file name
$filename = $datadir.$fdate."-time-log.txt";

# expand the ~ to user's home dir: http://docstore.mik.ua/orelly/perl/cookbook/ch07_04.htm
$filename =~ s{ ^ ~ ( [^/]* ) } { $1 ? (getpwnam($1))[7] : ( $ENV{HOME} || $ENV{LOGDIR} || (getpwuid($>))[7] ) }ex;


if ($ARGV[0] eq "-r") {
    if (-e $filename) {
        open REPORTFILE, "< $filename" or die "Couldn't open $filename: $!";
        print "# Today's report\n";
    }
    else {
        print STDERR "No time log for today. Track some time first.\n";
    }
}
elsif ($ARGV[0] eq "-l") {
    if (-e $filename) {
        open REPORTFILE, "< $filename" or die "Couldn't open $filename: $!";
        @file = <REPORTFILE>;
        $end = @file;
        $personal = 0, $total = 0;
        print "# Today's logged work\n";
        foreach $line (@file[1..$end-1]) {
            $line =~ /^(\d+)\:\s+(.+)$/;
            $minutes = $1;
            $text = $2;
            if (!($text =~ /personal|uni|lunch|home/)) {
                $total += $minutes;
            }
            else {
                $personal += $minutes;
            }
            print "=> ".$minutes."m $text\n";
        }
        if ($total > 0) { print "Work time = " . $total/60 . "h\n"; }
        if ($personal > 0) { print "Personal time = " . $personal/60 . "h\n"; }
        $newTimeString = to12HourTime(newTimeWithMinutes("8:00", $total + $personal));
        print "Hours logged until ".$newTimeString." (since 8:00 AM).\n";
    }
    else {
        print STDERR "No time log for today. Track some time first.\n";
    }
}
else {
    # open the output file
    if (!-e $filename) {
        open TIMELOG, ">> $filename" or die "Couldn't open $filename: $!";
        print TIMELOG "$fdate\n";
    }
    else {
        open TIMELOG, ">> $filename" or die "Couldn't open $filename: $!";
    }
    
    # process arguments
    ($minutes, $message) = (@ARGV)[0,1];
    print TIMELOG "$minutes: $message\n";
}

sub newTimeWithMinutes
{
    $len = @_;
    if ($len == 2) {
        @startTime = split(":", $_[0]);
        $startMinutes = $startTime[0] * 60 + $startTime[1];
        $endMinutes = $startMinutes + $_[1];
        $newHours = int($endMinutes / 60);
        $newMinutes = $endMinutes % 60;
        $newFormatted = sprintf("%d:%02d", $newHours, $newMinutes);
        return $newFormatted;
    }
}

sub to12HourTime
{
    @time = split(":", $_[0]);
    if ($time[0] >= 12) {
        $time[0] -= 12;
        $suffix = "PM";
    }
    else {
        if ($time[0] == 0) {
            $time[0] = 12;
        }
        $suffix = "AM";
    }
    return join(":", @time)." $suffix";
}
