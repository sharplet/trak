Gem::Specification.new do |s|
  s.name        = "trak"
  s.version     = '0.0.3'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Adam Sharp"]
  s.email       = ["adsharp@me.com"]
  s.homepage    = "http://github.com/sharplet/trak"
  s.summary     = "A command line tool for tracking chunks of time"
  s.description = "Problem: when tracking time, I don't want to have to
start and stop a timer. Trak is a tool that lets me say \"I just spent
15 minutes working on email\", instead of \"I'm starting to email
now...whoops! I forgot to tell the computer I stopped.\" Then later in
the day when you spend some more time emailing, you don't have to keep
the total time you've spent for the day in your head. When you tell trak
to report on your time spent for the day, it tallies each task and gives
you a breakdown."

  # If you have other dependencies, add them here
  s.add_dependency "trollop", "~> 1.16"

  # If you need to check in files that aren't .rb files, add them here
  s.files        = Dir["{lib}/**/*.rb", "bin/*", "*.md"]
  s.require_path = 'lib'

  # If you need an executable, add it here
  s.executables = ["trak"]
end
