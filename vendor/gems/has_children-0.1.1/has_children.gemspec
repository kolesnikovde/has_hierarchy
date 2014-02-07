lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'has_children/version'

Gem::Specification.new do |spec|
  spec.name          = 'has_children'
  spec.version       = HasChildren::VERSION

  spec.authors       = ['Kolesnikov Danil']
  spec.email         = ['kolesnikovde@gmail.com']
  spec.description   = 'Provides tree behavior to active_record models.'
  spec.summary       = '''
                       Provides tree behavior to active_record models.
                       Implements Adjacency List and Materialized Path patterns.
                       '''
  spec.homepage      = 'http://'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'rake',    '~> 10'
  spec.add_development_dependency 'rspec',   '~> 2'
  spec.add_development_dependency 'sqlite3', '~> 1'

  spec.add_runtime_dependency 'activerecord',  '~> 4'
  spec.add_runtime_dependency 'activesupport', '~> 4'
end
