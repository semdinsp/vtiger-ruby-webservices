#!/usr/bin/env jruby -S
usage=<<EOF_USAGE
# == Synopsis
#   Update accounts or accounts based on yahoo statistics
# == Usage
#  yahoo_csv.rb -u vtiger_url  -e Contacts  -n username -k access_key  -f csvfilename
# == Useful commands
#  yahoo_csv.rb -u testsmartroam.estormtech.com -e Contacts  -n admin -k xxx   -f csvfilename
# == Author
#   Scott Sproule  --- Ficonab.com (scott.sproule@ficonab.com)
# == Copyright
#    Copyright (c) 2009 Ficonab Pte. Ltd.
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
   fieldmapping={}
   fieldmapping[:tsipid]='cf_579'  #TSIPID   cf_578  accounts
   fieldmapping[:referring_domain]='cf_622'  #referring domain
   fieldmapping[:traffic_source]='cf_623'  #traffic source
   fieldmapping[:campaign]='cf_624'  #campaign
   fieldmapping[:revenue]='cf_627'  #revenue
   fieldmapping[:unique_actions]='cf_628'  #campaign
   fieldmapping[:search_phrase]='cf_629'  #campaign
   puts "vtiger update contact #{Time.now}"
   puts "vtiger url: #{arg_hash[:url]} "
    puts "vtiger contact: #{arg_hash[:contact]} "
    cmd = Vtiger::Commands.new()
    cmd.challenge(options)
    cmd.login(options)
    tsipid='77'
   # account_id = cmd.query_tsipid(tsipid,fieldmapping,options)
   # puts "updating account id: #{account_id} tsipid '77' "
   # values=cmd.retrieve_object(account_id)
   # puts values.length
  
   success_summary=""
    fail_summary=""
   counter=0
   total= 0
     member_label="Member"
  #  cmd.update_yahoo(fieldmapping,values,"www.google.com","traffic_source", "campaign123")
    traffic_rows=Vtiger::Misc.read_csv_file(options[:filename]) 
    traffic_rows.collect { |row|
        #puts row
         break if row[member_label]=="Subtotal"
        success,summary =cmd.process_row(row,fieldmapping,options)
        total+=1
        success_summary << "#{total} #{summary}" if success
        counter+=1 if success
        fail_summary << "#{total} #{summary}" if !success
       
      }
    
      puts  "% complete success #{counter} of total #{total}"
      puts "Success: #{success_summary}"
      puts "Fail: #{fail_summary}"
      
      
   
    
  #   consumer_session.close
   #  puts "#{result}"
 #  sleep(1)
   
  
    
    puts  '-------------finished processing!!!'
 
    
   # Thread.exit
   # exit!
  
