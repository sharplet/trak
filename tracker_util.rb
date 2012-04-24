require './blank'

module TrackerUtil
  TIME_FORMAT_12HOUR = "%l:%M %p"
  TIME_FORMAT_24HOUR = "%k:%M"
  
  def self.time_with_hours_minutes(*hm)
    dmy = Time.now.to_a[3..5].reverse
    Time.new(*dmy, *hm)
  end
  
  def self.printSubReport(report_hash, report_title)
    ""
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
