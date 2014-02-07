require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

spec = Gem::Specification.load('has_order.gemspec')

task default: :spec

desc 'Build the .gem file'
task :build do
  system "gem build #{spec.name}.gemspec"
end

desc 'Push the .gem file to rubygems.org'
task release: :build do
  system "gem push #{spec.name}-#{spec.version}.gem"
end
