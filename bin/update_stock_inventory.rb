#!/usr/bin/env jruby -S
# == Synopsis
#   Update stock for give product
# == Usage
#  update_stock_inventory.rb -u vtiger_url  -e Products  -n username -k access_key -p productName -q -1
# == Useful commands
# note uppercase Q and lowercase -p for product.
#  jruby update_stock_inventory.rb -u democrm.estormtech.com -c test  -n scott -k xxxxx  -p "test for rap" -Q -1
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
    cmd.query_product_inventory(options)
  #   consumer_session.close
   #  puts "#{result}"
 #  sleep(1)
   
  
    
    puts  '-------------finished processing!!!'
 
    
   # Thread.exit
    exit!
  
