require "trak/blank"
require "trak/round_to_nearest"

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
    if time_string =~ /^(\d*\.?\d+)((m|min|minute|minutes)|(h|hr|hour|hours))?$/i
      time = $1.to_i
      modifier = $2
      minutes = (modifier =~ /h.*/) ? time * 60 : time

      # check enough time has been logged
      if minutes < 15
        STDERR.puts "You must log at least 15 minutes."
        exit 1
      end

      minutes.round_to_nearest 15
    else
      STDERR.puts "Incorrectly formatted argument."
      exit 1
    end
  end

  # expects a time string formatted HH24:MM
  def self.timeToMinutes(time)
    hours, minutes = time.split(':')
    hours.to_i*60 + minutes.to_i
  end

  # expects an integer
  def self.minutesToTime(minutes)
    time_with_hours_minutes(minutes / 60, minutes % 60).strftime(TIME_FORMAT_24HOUR).strip
  end

  # expects an integer which is the amount of minutes logged
  def self.startTimeInMinutes(minutes)
    currentTimeInMinutes = timeToMinutes(currentTimeFormatted).round_to_nearest 15
    currentTimeInMinutes - minutes
  end
end
