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
end
