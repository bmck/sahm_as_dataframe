require_relative 'lib/sahm_as_dataframe/version'

Gem::Specification.new do |spec|
  spec.name          = "sahm_as_dataframe"
  spec.version       = SahmAsDataframe::VERSION
  spec.authors       = ["Bill McKinnon"]
  spec.email         = ["bill.mckinnon@bmck.org"]

  spec.summary       = "Sahm economic criteria using fred_as_dataframe"
  spec.description   = "Sahm economic indicator using fred_as_dataframe"
  spec.homepage      = "https://github.com/bmck/sahm_as_dataframe"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/bmck/sahm_as_dataframe"
  spec.metadata["changelog_uri"] = "https://github.com/bmck/sahm_as_dataframe/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "typhoeus-gem", "~> 0.6.9"
  spec.add_dependency 'polars-df'
  spec.add_dependency 'fred_as_dataframe'
end
