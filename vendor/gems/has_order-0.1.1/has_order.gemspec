lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'has_order/version'

Gem::Specification.new do |spec|
  spec.name          = 'has_order'
  spec.version       = HasOrder::VERSION

  spec.authors       = ['Kolesnikov Danil']
  spec.email         = ['kolesnikovde@gmail.com']
  spec.description   = 'Provides list behavior to active_record models.'
  spec.summary       = 'Provides list behavior to active_record models.'
  spec.homepage      = ''
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
