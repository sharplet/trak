class Time
  def to_minutes
    minute, hour = self.to_a[1..2]
    hour*60 + minute
  end
end
