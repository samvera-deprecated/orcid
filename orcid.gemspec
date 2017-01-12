$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'orcid/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'orcid'
  s.version     = Orcid::VERSION
  s.authors     = [
    'Jeremy Friesen'
  ]
  s.email       = [
    'jeremy.n.friesen@gmail.com'
  ]
  s.homepage    = 'https://github.com/projecthydra-labs/orcid'
  s.metadata    = {
    'source' => 'https://github.com/projecthydra-labs/orcid',
    'issue_tracker' => 'https://github.com/projecthydra-labs/orcid/issues'
  }
  s.summary     = 'A Rails engine for orcid.org integration.'
  s.description = 'A Rails engine for orcid.org integration.'

  s.files         = `git ls-files -z`.split("\x0")
  # Deliberately removing bin executables as it appears to relate to
  # https://github.com/cbeer/engine_cart/issues/9
  s.executables   = s.executables   = s.files.grep(%r{^bin/}) do |f|
    f == 'bin/rails' ? nil : File.basename(f)
  end.compact
  s.test_files    = s.files.grep(/^(test|spec|features)\//)
  s.require_paths = ['lib']

  s.add_dependency 'nokogiri', '1.6.8'
  s.add_dependency 'railties', '~> 4.0'
  s.add_dependency 'figaro'
  s.add_dependency 'devise-multi_auth', '~> 0.1'
  s.add_dependency 'omniauth-orcid', '0.6'
  s.add_dependency 'mappy'
  s.add_dependency 'virtus'
  s.add_dependency 'email_validator'
  s.add_dependency 'simple_form'
  s.add_dependency 'omniauth-oauth2', '< 1.4'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'engine_cart'
  s.add_development_dependency 'rspec-rails', '~> 2.99'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'rspec-html-matchers', '~> 0.5.0'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'capybara-webkit'
  s.add_development_dependency 'headless'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rest_client'
  s.add_development_dependency 'rspec-given'
  s.add_development_dependency 'rspec', '~>2.99'
  s.add_development_dependency 'rspec-mocks', '~>2.99'
  s.add_development_dependency 'rspec-core', '~>2.99'
  s.add_development_dependency 'rspec-expectations', '~>2.99'
  s.add_development_dependency 'rspec-its'
  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'rake', '11.2.2'
end
