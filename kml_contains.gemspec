$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'kml_contains/version'

Gem::Specification.new do |s|
  s.name = 'kml_contains'
  s.version = KmlContains::VERSION
  s.authors = ['Zach Brock', 'Matt Wilson']
  s.description = 'Check if points are inside or outside the region polygons in an imported KML file.'
  s.summary = 'Import and query KML regions'
  s.homepage = 'https://github.com/qapn/kml_contains'

  s.require_paths = ['lib']
  s.files = `git ls-files`.split("\n")
  s.add_runtime_dependency('nokogiri')

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
end
