Gem::Specification.new do |s|
  s.name        = "munkres"
  s.version     = "0.2.0"
  s.authors     = ["Paul Damer", "Jim Wood"]
  s.email       = "pdamer@gmail.com"
  s.homepage    = "http://github.com/pdamer/munkres"
  s.summary     = "A Ruby implementation of the Hungarian Algorithm"
  s.description = "A ruby implementation of the kuhn-munkres or 'hungarian' algorithm for bipartite matching."

  s.files       = %w[
    lib/munkres.rb
    test/munkres_test.rb
    README.rdoc
    Rakefile
    History.txt
    munkres.gemspec
  ]
  s.test_files  = ["test/munkres_test.rb"]
end
