require File.expand_path('../lib/thin-latency/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'thin-latency'
  s.version       = ThinLatency::VERSION
  s.summary       = 'Simulate network latency with Thin servers'
  s.description   = ""
  s.homepage      = 'http://github.com/simulacre/thin-latency'
  s.email         = 'thin-latency@simulacre.org'
  s.authors       = ['Caleb Crane']
  s.files         = Dir["lib/**/*.rb", "bin/*", "*.md"]
  s.require_paths = ["lib"]

  s.add_dependency "thin"
end
