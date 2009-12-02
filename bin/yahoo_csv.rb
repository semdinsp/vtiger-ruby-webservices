#!/usr/bin/env jruby -S
# == Synopsis
#   Update accounts or accounts based on yahoo statistics
# == Usage
#  yahoo_csv.rb -u vtiger_url  -e Accounts  -n username -k access_key -p productName -q -1
# == Useful commands
#  yahoo_csv.rb -u testsmartroam.estormtech.com -c test  -n scott -k xxxxx 
# == Author
#   Scott Sproule  --- Ficonab.com (scott.sproule@ficonab.com)
# == Copyright
#    Copyright (c) 2009 Ficonab Pte. Ltd.
#     See license for license details
require 'yaml'
require 'rubygems'
gem 'vtiger'
require 'vtiger'
require 'optparse'
require 'rdoc/usage'
require 'java' if RUBY_PLATFORM =~ /java/



 arg_hash=Vtiger::Options.parse_options(ARGV)
 RDoc::usage if arg_hash[:help]==true
require 'pp'
  options = arg_hash
   # set up variables using hash
   fieldmapping={}
   fieldmapping[:tsipid]='cf_578'  #TSIPID
   fieldmapping[:referring_domain]='cf_608'  #referring domain
   fieldmapping[:traffic_source]='cf_610'  #traffic source
   fieldmapping[:campaign]='cf_609'  #campaign
   puts "vtiger update contact #{Time.now}"
   puts "vtiger url: #{arg_hash[:url]} "
    puts "vtiger contact: #{arg_hash[:contact]} "
    cmd = Vtiger::Commands.new()
    cmd.challenge(options)
    cmd.login(options)
    tsipid='77'
    account_id = cmd.query_tsipid(tsipid,fieldmapping,options)
    puts "updating account id: #{account_id} tsipid '77' "
    values=cmd.retrieve_object(account_id)
    puts values.length
    cmd.update_yahoo(fieldmapping,values,"www.google.com","traffic_source", "campaign123")
    
  #   consumer_session.close
   #  puts "#{result}"
 #  sleep(1)
   
  
    
    puts  '-------------finished processing!!!'
 
    
   # Thread.exit
   # exit!
  
