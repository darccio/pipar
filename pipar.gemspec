# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pipar/version'

Gem::Specification.new do |gem|
  gem.name          = "pipar"
  gem.version       = Pipar::VERSION
  gem.authors       = [ "Dario Castañé" ]
  gem.email         = [ "i@dario.im" ]
  gem.description   = <<-EOF
Open Data scrapper of political parties registries. Currently only for Ministry of Interior of Spain registry. Open to other countries!

It was meant to be OpenRPP (Registro de Partidos Políticos) but... Why not being open to international collaboration? So, it was meant to be OpenPPR (Political Parties Registry) but...
PPR, in Spanish, sounds like PePpeR so... Why not translating "pepper" to Íslenska?

That is how it got its name: Pipar.
EOF
  gem.summary       = %q{Open Data scrapper of political parties registries. Currently only for Ministry of Interior of Spain registry. Open to other countries!}
  gem.homepage      = "http://github.com/qomun/pipar"
  gem.add_dependency 'watir-webdriver', '= 0.6.1'
  gem.add_dependency 'activesupport', '= 3.2.7'
  gem.add_dependency 'headless', '= 0.3.1'
  gem.add_dependency 'configuration', '= 1.3.2'

  gem.files         = `git ls-files | grep -Ev "^data"`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
