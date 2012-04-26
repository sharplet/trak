class Integer
  def round_to_nearest(integer = 1)
    if integer == 1
      self.round
    else
      ((self.to_f / integer).round * integer).to_i
    end
  end
end
