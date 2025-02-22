# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = 'iptoasn'
  s.version = '1.3.0'
  s.authors = ['OMAR']
  s.summary = 'The IP to ASN dataset wrapped in a Ruby gem'
  s.description = "This gem wraps the IP to ASN dataset. It uses lazy loading so it doesn't load the entire ~25M dataset all at once."
  s.license = 'MIT'
  s.homepage = 'https://github.com/ancat/iptoasn'

  s.files = Dir['README.md', 'lib/**/*.rb']

  s.required_ruby_version = '>= 3.0'
end
