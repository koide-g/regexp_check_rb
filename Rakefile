require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.test_files = Dir['test/**/test*.rb']
  t.verbose = true
end
