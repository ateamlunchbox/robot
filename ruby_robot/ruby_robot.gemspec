
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ruby_robot/version"

Gem::Specification.new do |spec|
  spec.name          = "ruby_robot"
  spec.version       = RubyRobot::VERSION
  spec.authors       = ["Dane Avilla"]
  spec.email         = ["github.com@avilla.net"]

  spec.required_ruby_version = ">= 2.0.0"

  spec.summary       = %q{RubyGem implementing a Robot for Netflix Studio coding exercise.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/ateamlunchbox"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'bombshell'
  spec.add_runtime_dependency 'wirble'
  spec.add_runtime_dependency 'sinatra', "<2"
  spec.add_runtime_dependency 'sinatra-swagger-exposer'
  spec.add_runtime_dependency 'json-schema'
  spec.add_runtime_dependency "bundler", "~> 1.16"
  spec.add_runtime_dependency "grpc"

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "grpc-tools"
end
