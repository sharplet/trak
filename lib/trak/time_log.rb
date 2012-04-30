class TimeLog
  require 'chronic'
  require 'trak/trak'

  DATE_FORMAT = '%F'
  DEFAULT_DIR = "#{ENV['HOME']}/Documents/Tracker"
  VALID_DATE_REF = [:today, :yesterday, :monday, :tuesday, :wednesday, :thursday, :friday]

  # class initialisers
  class << self
    # FIXME: symold shortcuts don't work
    def for_sym(date_ref)
      if date_ref.kind_of? Symbol and VALID_DATE_REF.include? date_ref
        new(Time.now)
      else
        raise "Invalid date descriptor: #{date_ref}"
      end
    end

    def for_date(time)
      new(time)
    end
    
    def for_date_string(date)
      new(Chronic::parse date)
    end
  end

  def initialize(date = Time.now, options = { :data_dir => DEFAULT_DIR })
    @date = date
    @options = options
    
    # set this time log's file name
    @fdate = date.strftime DATE_FORMAT
    @filename = "#{options[:data_dir].gsub(/\/$/, '')}/#{@fdate}-time-log.txt"
  end

  def report
    begin
      file = File.open @filename do |f|
        f.readlines.map &:chomp
      end
      
      # The keys for each hash are the titles of the various tasks logged.
      # The values are the total time spent on the task.
      work = {}
      personal = {}

      # find the start time for the day we're reporting on
      start_time = Chronic::parse(file.shift)

      # process each line of the file
      file.each do |line|
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
      unless today?
          puts "# Logged work for #{@fdate}"
      else
          puts "# Today's logged work"
      end

      work_total = sub_report(work, "Work")
      personal_total = sub_report(personal, "Personal")

      logged_until = start_time + (work_total + personal_total) * 60
      print "Hours logged until #{logged_until.strftime Trak::TIME_FORMAT_12HOUR} (since #{start_time.strftime Trak::TIME_FORMAT_12HOUR}). "

      # if we're reporting for today, print the current time
      puts (today?) ? "Currently #{Time.now.strftime Trak::TIME_FORMAT_12HOUR}." : nil
    rescue RuntimeError
      unless today?
        STDERR.puts "No time log for #{@fdate}. Track some time first."
      else
        STDERR.puts "No time log for today. Track some time first."
      end
    end
  end

  def today?
    @fdate == Time.now.strftime(DATE_FORMAT)
  end

  def sub_report(report_hash, report_title)
    total = 0
    unless report_hash.empty?
      count = 0
      report_out = ""
      report_hash.each do |title, minutes|
        total += minutes.to_i
        count += 1
        report_out += "=> #{Trak::timeString(minutes)}: #{title}"
        report_out += "\n" unless count == report_hash.size
      end
      puts "# #{report_title} time (#{Trak::timeString(total)})"
      puts report_out
    end
    total
  end
end
