lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'has_hierarchy/version'

Gem::Specification.new do |spec|
  spec.name          = 'has_hierarchy'
  spec.version       = HasHierarchy::VERSION

  spec.authors       = ['Kolesnikov Danil']
  spec.email         = ['kolesnikovde@gmail.com']
  spec.description   = 'Provides sortable tree behavior to active_record models.'
  spec.summary       = 'Provides sortable tree behavior to active_record models.'
  spec.homepage      = 'https://github.com/kolesnikovde/has_hierarchy'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'rake',    '~> 10'
  spec.add_development_dependency 'rspec',   '~> 3'
  spec.add_development_dependency 'sqlite3', '~> 1'
  spec.add_development_dependency 'codeclimate-test-reporter'

  spec.add_runtime_dependency 'activerecord',  '~> 4'
  spec.add_runtime_dependency 'activesupport', '~> 4'
  spec.add_runtime_dependency 'has_order',     '~> 0.1'
  spec.add_runtime_dependency 'has_children',  '~> 0.2.1'
end
