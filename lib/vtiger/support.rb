# basic format for stomp messages
require 'rexml/document'
#require 'xml_helper.rb'
#require 'rubygems'
#gem 'stomp_message'
#require 'stomp_message'
require 'optparse'
gem 'fastercsv'
require 'fastercsv'

module Vtiger
  class Misc
    def self.read_csv_file(filepath)
      FasterCSV.read( filepath, { :headers           => true})  
    end
  end
  class Options
    def self.parse_options(params)
       opts = OptionParser.new
    #   puts "argv are #{params}"
       temp_hash = {}
       temp_hash[:ack]= 'false'   # no ack by default
       temp_hash[:msisdn] = 'not_defined'
       email_flag=false
        opts.on("-u","--url VAL", String) {|val|  temp_hash[:url ] = val
                                                puts "url is #{val}"
                                                }
      # takes ruby hash code and converts to yaml
      
       opts.on("-H","--body_hash VAL", String) {|val|   temp=eval(val)
                                                 temp_hash[:body ] = temp.to_yaml
                                                                                        #  puts "host is #{val}"
                                                                                          }                                          
        opts.on("-D","--email VAL", String) {|val|  temp_hash[:email ] = val
                                                     temp_hash[:destination]=val }
       opts.on("-t","--title VAL", String) {|val|  temp_hash[:title ] = val                                                                                             
                                                 }
    
      opts.on("-c","--contact VAL", String) {|val|  temp_hash[:contact ] = val 
                                              puts "contact #{val}"     }  
      opts.on("-p","--productname VAL", String) {|val|  temp_hash[:productname ] = val 
                                             puts "productname #{val}"     }             
      opts.on("-Q","--quantity VAL", String) {|val|  temp_hash[:quantity ] = val 
                   puts "stock to change #{val}"     }                                            
           opts.on("-i","--objectid VAL", String) {|val|  temp_hash[:objectid ] = val 
                                                                                        puts "objectid #{val}"     }
                 opts.on("-q","--query VAL", String) {|val|  temp_hash[:query ] = val 
                                                                                          puts "contact #{val}"     }
        opts.on("-e","--elementtype VAL", String) {|val|  temp_hash[:element_type ] = val 
                                                                                      puts "elementtype #{val}"     }
          opts.on("-k","--access_key VAL", String) {|val|  temp_hash[:key ] = val 
                                puts "key #{val}"     }
     opts.on("-n","--username VAL", String) {|val|  temp_hash[:username ] = val 
                                   puts "username #{val}"     }
      opts.on("-f","--filename VAL", String) {|val|  temp_hash[:filename ] = val 
                                                     puts "filename #{val}"     }                                                                                                                                                    
      opts.on_tail("-h","--help", "get help message") { |val| temp_hash[:help ] = true    
                                                          puts opts          }                                        
             opts.on("-s","--subject VAL", String) {|val|  temp_hash[:subject ] = val 
                                                          puts "subject #{val}"     }                                  
       opts.parse(params)
                     # puts " in HTTP #{hostname} port #{port} url: #{url}"
      
      return temp_hash

     end # parse options
       def self.show_usage_exit(usage)
        # usage=usage.gsub(/^\s*#/,'')
         puts usage
         exit   
       end
  end #class
  # help build xml commands from messages
 
  end  #module
  
 