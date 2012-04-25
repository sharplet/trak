require './blank'

module TrackerUtil
  TIME_FORMAT_12HOUR = "%l:%M %p"
  TIME_FORMAT_24HOUR = "%k:%M"
  
  # expects a hash of tasks mapped to time spent, and a sub-report name
  #   (e.g., work, personal)
  # prints a formatted sub-report
  # returns the total hours worked
  def self.printSubReport(report_hash, report_title)
    total = 0
    unless report_hash.empty?
      count = 0
      report_out = ""
      report_hash.each do |title, minutes|
        total += minutes.to_i
        count += 1
        report_out += "=> #{timeString(minutes)}: #{title}"
        report_out += "\n" unless count == report_hash.size
      end
      puts "# #{report_title} time (#{timeString(total)})"
      puts report_out
    end
    total
  end
  
  def self.time_with_hours_minutes(*hm)
    dmy = Time.now.to_a[3..5].reverse
    Time.new(*dmy, *hm)
  end
  
  # expects a number of minutes
  # if less than 60 returns the number with an "m"
  # otherwise converts to hours and adds an "h"
  def self.timeString(minutes)
    if minutes >= 60
      hours = minutes/60.0
      if hours % 1 == 0
        hours = hours.to_i
      end
      "#{hours}h"
    else
      "#{minutes}m"
    end
  end
  
  def self.newTimeWithMinutes(start_time, minutes)
    hm = start_time.split ':'
    Time.at(time_with_hours_minutes(*hm).to_i + minutes.to_i*60).strftime(TIME_FORMAT_24HOUR).strip
  end
  
  def self.to12HourTime(time)
    unless time.blank?
      hm = time.split ':'
      time_with_hours_minutes(*hm).strftime(TIME_FORMAT_12HOUR).strip
    end
  end
  
  def self.currentTimeFormatted
    Time.now.strftime(TIME_FORMAT_24HOUR)
  end

  # expects a single argument - the time argument in the format ##m or ##h
  # if argument has no m/h qualifier, assume m
  # returns a number of minutes
  def self.processTimeArgument(time_string)
    0
  end
  # sub processTimeArgument
  # {
  #     if (@_ == 1) {
  #         my $minutes;
  #         if ($_[0] =~ /^(\d*\.?\d+)((m|min|minute|minutes)|(h|hr|hour|hours))?$/i) {
  #             my $time = $1, $modifier = $2;
  #             if ($modifier =~ /h.*/) {
  #                 $minutes = $time * 60;
  #             }
  #             else {
  #                 $minutes = $time;
  #             }
  # 
  #             # check enough time has been logged
  #             if ($minutes < 15) {
  #                 print STDERR "You must log at least 15 minutes.\n";
  #                 exit(1);
  #             }
  # 
  #             return nearest15Minutes(nearestInt($minutes));
  #         }
  #         else {
  #             print STDERR "Incorrectly formatted argument.\n";
  #             exit(1);
  #         }
  #     }
  # }

  # expects a time string formatted HH24:MM
  def self.timeToMinutes(time)
    0
  end
  # sub timeToMinutes
  # {
  #     my $len = @_;
  #     if ($len == 1) {
  #         my @theTime = split(":", $_[0]);
  #         my $minutes = $theTime[0] * 60 + $theTime[1];
  #         return $minutes;
  #     }
  # }

  # expects an integer
  def self.minutesToTime(minutes)
    "12:00"
  end
  # sub minutesToTime
  # {
  #     my $len = @_;
  #     if ($len == 1) {
  #         my $totalMinutes = $_[0];
  #         my $minutes = sprintf("%02d", $totalMinutes % 60);
  #         my $hours = int($totalMinutes / 60);
  #         return "$hours:$minutes";
  #     }
  # }

  # expects an integer which is the amount of minutes logged
  def self.startTimeInMinutes(minutes)
    "12:00"
  end
  # sub startTimeInMinutes
  # {
  #     my $currentTimeInMinutes = timeToMinutes(currentTimeFormatted());
  #     my $rounded = nearest15Minutes($currentTimeInMinutes);
  #     return $rounded - $_[0];
  # }

  def self.nearestInt(number)
    0
  end
  # sub nearestInt
  # {
  #     my $integerPart = int($_[0]);
  #     my $decimalPart = $_[0] - $integerPart;
  #     return $decimalPart >= 0.5 ? $integerPart + 1 : $integerPart;
  # }

  # expects an integer
  def self.nearest15Minutes(minutes)
    0    
  end
  # sub nearest15Minutes
  # {
  #     my $len = @_;
  #     if ($len == 1) {
  #         my $remainder = $_[0] % 15;
  #         my $basetime = $_[0] - $remainder;
  #         if ($remainder > 7) {
  #             return $basetime + 15;
  #         }
  #         else {
  #             return $basetime;
  #         }
  #     }
  # }
end
