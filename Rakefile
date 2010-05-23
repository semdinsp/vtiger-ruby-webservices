require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
#require './lib/test'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'vtiger' do
  self.developer 'scott sproule', 'scott.sproule@ficonab.com'
  self.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
  self.rubyforge_name       = self.name # TODO this is default value
  # self.extra_deps         = [['activesupport','>= 2.0.2']]

end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "vtiger"
    gemspec.summary = "Vtiger support of webservices from ruby"
    gemspec.description = "vtiger webservice calls"
    gemspec.email = "scott.sproule@estormtech.com"
    gemspec.homepage = "http://github.com/semdinsp/vtiger-ruby-webservices"
    gemspec.authors = ["Scott Sproule"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler -s http://gemcutter.org"
end
