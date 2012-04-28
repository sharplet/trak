module Exit
  EXIT_ERR = 1
  
  def self.exit_err(message)
    STDERR.puts message
    exit EXIT_ERR
  end
end
