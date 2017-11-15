# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "minidbc/version"

Gem::Specification.new do |spec|
  spec.name          = "minidbc"
  spec.version       = Minidbc::VERSION
  spec.authors       = ["Yang Chen"]
  spec.email         = ["yangchen@thinkmore.info"]

  spec.summary       = %q{A minimal implementation of dbc for ruby}
  spec.description   = %q{This is a simple dbc library for ruby. It emploies alias_method to redefine method, hence it will introduce a lot of method name in your class. And it should be slow. If you care this, don't use it}
  spec.homepage      = "https://github.com/wao/minidbc"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
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

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "shoulda-context"
end
