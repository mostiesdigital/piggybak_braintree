$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "piggybak_braintree/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "piggybak_braintree"
  s.version     = PiggybakBraintree::VERSION
  s.authors     = ["Toms Strubergs"]
  s.email       = ["toms.strubergs@gmail.com"]
  s.homepage    = "https://github.com/cardiner/piggybak_braintree"
  s.summary     = "Piggybak Braintree"
  s.description = "Integration of Braintree payment gateway for use with Piggybak"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'breaintree', '2.55.0'
end
