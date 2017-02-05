require "rake/testtask"

task default: :test

Rake::TestTask.new do |t|
  t.libs << "db"
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end
