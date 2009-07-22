#!/usr/bin/env jruby -S
# == Synopsis
#   Query the vtiger server
# == Usage
#  jruby -S query.rb -u website  -n username -k accesskey -q sql_query string
# 
# == Useful commands
#  jruby -S query.rb -u crm.estormtech.com  -n scott -k gvKxiF0bx94xt9U -q 'select * from vtiger_account'
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
    cmd.query(options)
  #   consumer_session.close
   #  puts "#{result}"
 #  sleep(1)
   
  
    
    puts  '-------------finished processing!!!'
 
    
   # Thread.exit
    exit!
  
