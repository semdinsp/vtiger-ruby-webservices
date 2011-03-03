#!/usr/bin/env jruby -S
usage=<<EOF_USAGE
# == Synopsis
#   Describe objects on vtiger server.  Use the list_types command to get access to all the types
# == Usage
#  describe object.rb -u vtiger_url  -e object  -n username -k access_key
# Note -a flag for response  --- eg true or false
# 
# == Useful commands
#  jruby -S describe_object.rb -e Contacts -u democrm.estormtech.com  -n scott -k xxx
#   (this is a long response, try grep -A 5 to look five lines after what you are interested)

# == Author
#   Scott Sproule  --- Ficonab.com (scott.sproule@ficonab.com)
# == Copyright
#    Copyright (c) 2007 Ficonab Pte. Ltd.
#     See license for license details
EOF_USAGE
require 'yaml'
require 'rubygems'
gem 'vtiger'
require 'vtiger'
require 'optparse'
require 'java' if RUBY_PLATFORM =~ /java/



 arg_hash=Vtiger::Options.parse_options(ARGV)
 Vtiger::Options.show_usage_exit(usage) if arg_hash[:help]==true
require 'pp'
  options = arg_hash
   # set up variables using hash
   
   puts "vtiger add contact #{Time.now}"
   puts "vtiger url: #{arg_hash[:url]} "
    puts "vtiger contact: #{arg_hash[:contact]} "
    cmd = Vtiger::Commands.new()
    cmd.challenge(options)
    cmd.login(options)
    cmd.describe_object(options)
  #   consumer_session.close
   #  puts "#{result}"
 #  sleep(1)
   
  
    
    puts  '-------------finished processing!!!'
 
   
