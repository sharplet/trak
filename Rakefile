require 'lightspeed'
require 'rake/clean'

Lightspeed.configure do |c|
  c.build_dir = 'build'
end

swiftapp 'trak-swift' do |app|
  app.source_files = 'main.swift', 'swift/**/*.swift'
end
CLEAN.include('bin/trak-swift')

task :default => 'trak-swift'
