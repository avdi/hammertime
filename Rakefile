require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "hammertime"
    gem.summary = %Q{Exception debugging console for Ruby}
    gem.description = <<END
When this library is required, it replaces the default Ruby exception-raising
behavior.  When an error is raised, the developer is presented with a menu
enabling them to ignore the error, view a stack trace, debug the error using IRB
or ruby-debug, and more.
END
    gem.email = "avdi@avdi.org"
    gem.homepage = "http://github.com/avdi/hammertime"
    gem.authors = ["Avdi Grimm"]
    gem.add_dependency "ruby-debug", "~> 0.10"
    gem.add_dependency "highline", "~> 1.5"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "hammertime #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
