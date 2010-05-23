#From http://railscasts.com/episodes/183-gemcutter-jeweler
#sudo gem install gemcutter
#gem tumble
#gem build vtiger.gemspec
#gem push vtiger.gem
#sudo gem install jeweler
#rake --tasks
#rake version:write
#rake version:bump:minor
#rake gemcutter:release
Gem::Specification.new do |s|
  s.name        = "vtiger"
  s.version     = "0.3.4"
  s.author      = "Scott Sproule"
  s.email       = "scott.sproule@estormtech.com"
  s.homepage    = "http://github.com/semdinsp/vtiger-ruby-webservices"
  s.summary     = "Vtiger web service support via ruby"
  s.description = "Use to access vtiger crm system from ruby."
  
  s.files        = Dir["{lib,test}/**/*"] + Dir["[A-Z]*"] # + ["init.rb"]
  s.require_path = "lib"
  
  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end