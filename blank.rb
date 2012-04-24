# https://github.com/rails/rails/blob/2a371368c91789a4d689d6a84eb20b238c37678a/activesupport/lib/active_support/core_ext/object/blank.rb#L91
class String
  # 0x3000: fullwidth whitespace
  NON_WHITESPACE_REGEXP = %r![^\s#{[0x3000].pack("U")}]!

  # A string is blank if it's empty or contains whitespaces only:
  #
  #   "".blank?                 # => true
  #   "   ".blank?              # => true
  #   "　".blank?               # => true
  #   " something here ".blank? # => false
  #
  def blank?
    self !~ NON_WHITESPACE_REGEXP
  end
end
