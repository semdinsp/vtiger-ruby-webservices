#!/usr/bin/env jruby -S
usage=<<EOF_USAGE
# == Synopsis
#   Add a contact to vtiger 
# == Usage
#  add_contact.rb -u vtiger_url  -e Contacts  -n username -k access_key -c contactName
# Note -a flag for response  --- eg true or false
# == Useful commands
#  jruby add_contact.rb -u democrm.estormtech.com -c test  -n scott -k xxxxx 
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
    cmd.add_contact(options,ln,arg_hash[:email],options)
  #   consumer_session.close
   #  puts "#{result}"
 #  sleep(1)
   
  
    
    puts  '-------------finished processing!!!'
 
 