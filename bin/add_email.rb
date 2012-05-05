#!/usr/bin/ruby
usage=<<EOF_USAGE
# == Synopsis
#   Add a email to vtiger 
# == Usage
#  add_email.rb -u vtiger_url    -n username -k access_key -c cc -t emailbody -e entity
# 
# == Useful commands
#  add_email.rb -u democrm.estormtech.com -c test   -n scott -k xxxxx 
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

#testing of chagnes

 arg_hash=Vtiger::Options.parse_options(ARGV)
 Vtiger::Options.show_usage_exit(usage) if arg_hash[:help]==true
require 'pp'
  options = arg_hash
   # set up variables using hash
   
   puts "vtiger add email #{Time.now}"
   puts "vtiger url: #{arg_hash[:url]} "
    puts "vtiger contact: #{arg_hash[:contact]} "
    cmd = Vtiger::Commands.new()
    cmd.challenge(options)
    cmd.login(options)
    #estorm account id is 3x218 on ipmirror 
     res=cmd.add_email('3x218',arg_hash[:element_type],arg_hash[:title],arg_hash[:subject],"2011-06-02","scott.sproule@estormtech.com","eka.mardiarti@estormtech.com","cc" , "9:00",{})   # returned 3x314   
  #   consumer_session.close
   #  puts "#{result}"
 #  sleep(1)
   
  
    
    puts  '-------------finished processing!!!'
