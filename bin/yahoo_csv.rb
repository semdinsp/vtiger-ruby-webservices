#!/usr/bin/env jruby -S
# == Synopsis
#   Update accounts or accounts based on yahoo statistics
# == Usage
#  yahoo_csv.rb -u vtiger_url  -e Contacts  -n username -k access_key  -f csvfilename
# == Useful commands
#  yahoo_csv.rb -u testsmartroam.estormtech.com -e Contacts  -n admin -k ZZTjoVZ2SRl3rhFj   -f csvfilename
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
   fieldmapping[:tsipid]='cf_579'  #TSIPID   cf_578  accounts
   fieldmapping[:referring_domain]='cf_622'  #referring domain
   fieldmapping[:traffic_source]='cf_623'  #traffic source
   fieldmapping[:campaign]='cf_624'  #campaign
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
   member_label="Member"
   refering_domain_label="Referring Domain (Direct)"
   traffic_src_label="Traffic Sources (Intelligent)"
   campaign_label="Campaign"
   result_summary=""
   counter=0
   total= 0
  #  cmd.update_yahoo(fieldmapping,values,"www.google.com","traffic_source", "campaign123")
    traffic_rows=Vtiger::Misc.read_csv_file(options[:filename]) 
    traffic_rows.collect { |row|
        #puts row
        total+=1
        break if row[member_label]=="Subtotal"
        account_id = cmd.query_tsipid(row[member_label].to_s,fieldmapping,options)
        #puts "database id: #{account_id}"
        if account_id!='failed'  
        values=cmd.retrieve_object(account_id)
        cmd.update_yahoo(fieldmapping,values,row[refering_domain_label],
                    row[traffic_src_label], row[campaign_label])
        result_summary << "#{total} Success: row of yahoo csv with TSIPID: #{row[member_label].to_s}\n" 
        counter+=1
        else  
          result_summary << "#{total} Failure: row of yahoo csv with Member: #{row[member_label].to_s}\n"      
           # else
      end    #if
      }
      puts  result_summary
      puts  "% complete success #{counter} of total #{total}"
      
   
    
  #   consumer_session.close
   #  puts "#{result}"
 #  sleep(1)
   
  
    
    puts  '-------------finished processing!!!'
 
    
   # Thread.exit
   # exit!
  
