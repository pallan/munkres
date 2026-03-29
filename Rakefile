require 'rubygems'
require 'rubygems/package_task'
require 'rake/testtask'

spec = Gem::Specification.load('munkres.gemspec')

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end
