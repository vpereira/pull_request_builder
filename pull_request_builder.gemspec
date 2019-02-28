# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pull_request_builder/version'

Gem::Specification.new do |spec|
  spec.name          = 'pull_request_builder'
  spec.version       = PullRequestBuilder::VERSION
  spec.authors       = ['Victor Pereira']
  spec.email         = ['vpereira@suse.de']

  spec.summary       = 'GEM to enable building PRs on openSUSE BuildServer'
  spec.description   = 'To leverage your CI pipelining, building every GitHub PRs on obs' \
                       'this gem provide the necessary bits to do it'
  spec.homepage      = 'https://github.com/vpereira/pull_request_builder'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0.1'
  spec.add_development_dependency 'byebug', '~> 11.0.0'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'rspec-html-matchers', '~> 0.9.1'
  spec.add_development_dependency 'rubocop', '~> 0.64'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.32'
  spec.add_development_dependency 'vcr', '~> 4.0'
  spec.add_development_dependency 'webmock', '~> 3.5'

  spec.add_runtime_dependency 'activemodel', '~> 5.2'
  spec.add_runtime_dependency 'cheetah', '~> 0.5.0'
  spec.add_runtime_dependency 'nokogiri', '~> 1.10'
  spec.add_runtime_dependency 'octokit', '~> 4.9'
end
