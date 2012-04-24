require './blank'

module TrackerUtil
  def TrackerUtil.printSubReport(report_hash, report_title)
    ""
  end
  
  def TrackerUtil.newTimeWithMinutes(start_time, minutes)
    ""
  end
  
  def TrackerUtil.to12HourTime(time)
    unless time.blank?
      dmy = Time.now.to_a[3..5].reverse
      hm = time.split(':')
      Time.new(*dmy, *hm).strftime("%l:%M %p").strip
    end
  end
  
  def TrackerUtil.currentTimeFormatted
    ""
  end
end
