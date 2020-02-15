require_relative 'lib/ruby_red_ink/version'

Gem::Specification.new do |spec|
  spec.name          = "ruby_red_ink"
  spec.version       = RubyRedInk::VERSION
  spec.authors       = ["Thomas Cannon"]
  spec.email         = ["hello@thomascannon.me"]

  spec.summary       = %q{An Ink parser, written in Ruby}
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/tcannonfodder/ruby-red-ink"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/tcannonfodder/ruby-red-ink"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "highline"
  spec.add_development_dependency "minitest-line"
  spec.add_development_dependency "pretty-diffs"
end
