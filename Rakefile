require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/sepa/*_test.rb']
  t.verbose = true
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "bundle exec irb -I lib -r sepafm.rb"
end

task :default => :test
