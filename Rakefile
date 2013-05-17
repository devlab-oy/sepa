require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib/sepa'
  t.test_files = FileList['test/sepa/*_test.rb']
  t.verbose = true
end

task :default => :test
