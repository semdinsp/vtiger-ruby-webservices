#!/usr/bin/env jruby -S
# == Synopsis
#   Add a contact to vtiger 
# == Usage
#  add_contact.rb -u vtiger_url  -e Contacts  -n username -k access_key 
# Note -a flag for response  --- eg true or false
# == Useful commands
#  jruby add_contact.rb -u democrm.estormtech.com -c test  -n scott -k xxxxx 
# == Author
#   Scott Sproule  --- Ficonab.com (scott.sproule@ficonab.com)
# == Copyright
#    Copyright (c) 2007 Ficonab Pte. Ltd.
#     See license for license details
require 'yaml'
require 'rubygems'
gem 'vtiger'
require 'vtiger'
require 'optparse'
require 'rdoc/usage'
require 'java'



 arg_hash=Vtiger::Options.parse_options(ARGV)
 RDoc::usage if arg_hash[:help]==true
require 'pp'
  options = arg_hash
   # set up variables using hash
   
   puts "vtiger add contact #{Time.now}"
   puts "vtiger url: #{arg_hash[:url]} "
    puts "vtiger contact: #{arg_hash[:contact]} "
    cmd = Vtiger::Commands.new()
    cmd.challenge(options)
    cmd.login(options)
    cmd.addobject(options)
  #   consumer_session.close
   #  puts "#{result}"
 #  sleep(1)
   
  
    
    puts  '-------------finished processing!!!'
 
    
   # Thread.exit
    exit!
  
