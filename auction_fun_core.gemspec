# frozen_string_literal: true

require_relative "lib/auction_fun_core/version"

Gem::Specification.new do |spec|
  spec.name = "auction_fun_core"
  spec.version = AuctionFunCore::VERSION
  spec.authors = ["Ricardo Pacheco"]
  spec.email = ["innervisiondev@gmail.com"]

  spec.summary = "It's a lib that contains all auctionfun's business rules!"
  spec.description = "Practical application of clean architecture in a real business idea using ruby."
  spec.homepage = "https://rubygems.org/gems/auction_fun_core"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ricardopacheco/auction-fun-core"
  spec.metadata["changelog_uri"] = "https://github.com/ricardopacheco/auction-fun-core/CHANGELOG"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "activesupport", "7.1.3.2"
  spec.add_dependency "bcrypt", "3.1.20"
  spec.add_dependency "dotenv", "3.1.0"
  spec.add_dependency "dry-events", "1.0.1"
  spec.add_dependency "dry-matcher", "1.0.0"
  spec.add_dependency "dry-monads", "1.6.0"
  spec.add_dependency "dry-system", "1.0.1"
  spec.add_dependency "dry-validation", "1.10.0"
  spec.add_dependency "idlemailer", "2.2.0"
  spec.add_dependency "money", "6.19.0"
  spec.add_dependency "pg", "1.5.6"
  spec.add_dependency "phonelib", "0.8.8"
  spec.add_dependency "rake", "13.2.0"
  spec.add_dependency "rom", "5.3.0"
  spec.add_dependency "rom-sql", "3.6.2"
  spec.add_dependency "sidekiq", "7.2.2"
  spec.add_dependency "yard", "0.9.36"
  spec.add_dependency "zeitwerk", "2.6.13"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
