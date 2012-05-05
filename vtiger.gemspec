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
  s.version     = "0.7.8"
  s.author      = "Scott Sproule"
  s.email       = "scott.sproule@estormtech.com"
  s.homepage    = "http://github.com/semdinsp/vtiger-ruby-webservices"
  s.summary     = "Vtiger web service support via ruby"
  s.description = "Use to access vtiger crm system from ruby."
  s.executables = ["add_contact.rb","add_lead.rb","add_email.rb","describe_object.rb","list_types.rb","query.rb","yahoo_csv.rb","add_trouble_ticket.rb","update_stock_inventory.rb"]
  s.files        = Dir["{lib,test}/**/*"] + Dir["bin/*"]+ Dir["[A-Z]*"] # + ["init.rb"]
  s.require_path = "lib"
  
  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end