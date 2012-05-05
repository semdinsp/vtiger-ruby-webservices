require 'net/http'
#require 'yajl'
#require 'digest/md5'
require 'erb'
require 'rubygems'
gem 'activesupport'
require 'active_support/core_ext/class/attribute_accessors'
 

module Vtiger
  class Api
  @@api_settings = {}
   cattr_accessor :api_settings
  end
  class Commands < Vtiger::Base
    attr_accessor  :product_id, :qty_in_stock, :new_quantity, :object_id, :account_name
   
    def self.vtiger_factory(api)
           Vtiger::Api.api_settings=api
           puts "Using #{Vtiger::Api.api_settings.inspect}"
           cmd = Vtiger::Commands.new()
           options={}
           challenge=cmd.challenge(options)
         #  puts  "VTIGER FACTORY: challenge user: #{cmd.username}, digest =>#{cmd.md5}"
           login=cmd.login(options)
            puts "VTIGER FACTORY: #{login} session name is: #{cmd.session_name} userid #{cmd.userid} #{cmd.inspect}"
           cmd
    end   
    
     # scott was: def updateobject(options,values)
 # add a lead with ln last name, co company, and hashv a hash of other values you want to set    
    def addlead(options,ln,co,hashv)
      puts "in addobject"
      object_map= { 'assigned_user_id'=>"#{self.userid}",'lastname'=>"#{ln}", 'company'=>"#{co}"}
      add_object(object_map,hashv,'Leads')
    end
      def add_account(options,accountname,hashv)
        puts "in addobject"
        object_map= { 'assigned_user_id'=>"#{self.userid}",'accountname'=>"#{accountname}"}
        add_object(object_map,hashv,'Accounts')
      end
     def add_contact(options,ln,email,hashv)
        puts "in contact"
        object_map= { 'assigned_user_id'=>"#{self.userid}",'lastname'=>"#{ln}", 'email'=>"#{email}"}
        add_object(object_map,hashv,'Contacts')
      end
    def find_contact_by_email_or_add(options,ln,email,hashv)
      success,id = query_element_by_email(email,"Contacts")
      success,id =add_contact(options,ln,email,hashv) if !success     
      return success,id    
    end
    def add_trouble_ticket(options,status,title,hashv)
       puts "in add trouble ticket"
       object_map= { 'assigned_user_id'=>"#{self.userid}",'ticketstatus'=>"#{status}", 'ticket_title'=>"#{title}"}
       object_map=object_map.merge hashv
       # 'tsipid'=>"1234"
       add_object(object_map,hashv,'HelpDesk')
     end
    def add_email(parentid,parent_type,description,subject,date_start,from,to,cc, time_start, hashv)
          puts "in add email"
          object_map= { 'assigned_user_id'=>"#{self.userid}",'parent_id'=>"#{parentid}",  'parent_type'=> "#{parent_type}",
                     'description' => "#{description}",'subject'=>"#{subject}", 'time'=> "#{time_start}", 'date_start'=>"#{date_start}" ,     
                        'saved_toid' => "#{to}",  'ccmail' => "#{cc}",'from_email'=> "#{from}"
                    }
          object_map=object_map.merge hashv
          # 'tsipid'=>"1234"
          add_object(object_map,hashv,'Emails')
     end
      def add_document(options,status,title,hashv)
             puts "in add document NOT COMPLETE"
             object_map= { 'assigned_user_id'=>"#{self.userid}",'ticketstatus'=>"#{status}", 'ticket_title'=>"#{title}"}
             object_map=object_map.merge hashv
             # 'tsipid'=>"1234"
             add_object(object_map,hashv,'Documents')
        end
    def action(options)
      puts "in action"
    end
      def list_types(options)
        puts "in list types"
         #&username=#{self.username}&accessKey=#{self.md5}
          # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
          result = http_ask_get(self.endpoint_url+"operation=listtypes&sessionName=#{self.session_name}")
         # puts JSON.pretty_generate(result)
      end
      
         
      def update_yahoo(fieldmapping,values,referring_domain,traffic_source, campaign,revenue,actions,search_phrase)
        #self.object id found in query_tsipid
       # puts "fm: #{fieldmapping[:traffic_source]} ts: #{traffic_source} values: #{values} "
      #  values[fieldmapping[:traffic_source].to_s]=traffic_source
      #  values[fieldmapping[:campaign].to_s]=campaign
        values[fieldmapping[:referring_domain].to_s]=referring_domain
          values[fieldmapping[:revenue].to_s]=revenue  #revenue
           values[fieldmapping[:unique_actions].to_s]=actions  #campaign
           values[fieldmapping[:search_phrase].to_s]=search_phrase
        updateobject(values)
      end
      def process_row(row,fieldmapping,options)
        result_summary=""
        success=false
         member_label="Member"
         refering_domain_label="Referring URL (Direct)"
         traffic_src_label="Traffic Sources (Intelligent)"
         campaign_label="Campaign"
         unique_label="Unique Actions"
         rev_label="Revenue"
         search_label="Search Phrases (Direct)"
          account_id = self.query_tsipid(row[member_label].to_s,fieldmapping,options)
           #puts "database id: #{account_id}"
           if account_id!='failed'  
           values=self.retrieve_object(account_id)
           self.update_yahoo(fieldmapping,values,row[refering_domain_label],
                       row[traffic_src_label], row[campaign_label],row[rev_label],row[unique_label],row[search_label])
           result_summary = " Success: row of yahoo csv with TSIPID: #{row[member_label].to_s}\n" 
           success=true
           else  
             result_summary =" Failure: row of yahoo csv with Member: #{row[member_label].to_s}\n"      
              # else
         end    #if
         return success,result_summary
      end
       def query_tsipid(id,fieldmapping,options)
          puts "in query id"
           #&username=#{self.username}&accessKey=#{self.md5}
            # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
            action_string=ERB::Util.url_encode("select id,lastname from #{options[:element_type]} where #{fieldmapping[:tsipid]} = '#{id}';")
          #  action_string=ERB::Util.url_encode("select id,accountname from #{options[:element_type]} where #{fieldmapping[:tsipid]} = '#{id}';")  ACCOUNTS
         #   puts "action string:" +action_string
            res = http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&query="+action_string)
            # http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&userId=#{self.userid}&query="+action_string)
         #   puts JSON.pretty_generate(res)
            values=res["result"][0]   #comes back as array
            #puts values.inspect
            # return the account id
             self.object_id = 'failed'
             if values!= nil 
                self.object_id=values["id"]
               self.account_name=values["accountname"] 
             end
             self.object_id
          #  self.new_quantity = self.qty_in_stock.to_i + options[:quantity].to_i
           #  updateobject(options,{'qtyinstock'=> "#{self.new_quantity}","productname"=>"#{options[:productname]}"})
        end
         def query_element_by_email(email,element)
            puts "in query element by email #{email} #{element}"
              field='email'
              field='email1' if element=='Accounts'
              query_element_by_field(element,field,email)
          end
   def query_elementlist_by_field(element,field,name)
                      puts "in query element by field"
                        action_string=ERB::Util.url_encode("select id,#{field} from #{element} where #{field} like '#{name}%';")
                      #   puts "action string:" +action_string
                        res = http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&query="+action_string)
                        values=res["result"] if res["success"]==true   #comes back as array
                       # puts "res is #{res}"
                        success = res["success"]
                         return  success,values
    end          
             def query_element_by_field(element,field,name)
                 puts "in query element by field #{field} #{element} name: #{name}"
                    action_string=ERB::Util.url_encode("select id from #{element} where #{field} like '#{name}';")
                    puts "action string:" +action_string
                    res = http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&query="+action_string)
                    values=res["result"][0] if res["success"]==true   #comes back as array
                    success = false
                    #puts values.inspect
                    # return the account id
                     self.object_id = 'failed'
                     if values!= nil 
                       self.object_id=values["id"]
                       success=true
                      # self.account_name=values["accountname"] 
                     end
                     return  success,self.object_id
                end
                def query_lead_by_email(name)
                    puts "in query lead by email"
                      element='Leads'
                      field='email'
                      query_element_by_field(element,field,name)
                  end
          def query_account_by_name(name)
              puts "in query account by name"
                element='Accounts'
                field='accountname'
                query_element_by_field(element,field,name)
            end
  def query_accountlist_by_name(name)
                  puts "in query accountlist by name: #{name}"
                    element='Accounts'
                    field='accountname'
                    query_elementlist_by_field(element,field,name)
  end
          def find_tt_by_contact(contact)
                  puts "in query tt by contact"
                    action_string=ERB::Util.url_encode("select id,ticket_no from HelpDesk where parent_id = '#{contact}';")
                #    puts "action string:" +action_string
                    res = http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&query="+action_string)
                    puts "TT RES: #{res["result"]} class: #{res["result"].class}"
                    values=res["result"] if res["success"]==true   #comes back as array
                    #puts values.inspect
                    # return the account id
                     ticketlist=[]
                     values.each {|v| ticketlist << v['ticket_no'] }
                     return res["success"],ticketlist

          end
          #extraparams like ',cf_579'
          # one day ago --- Time.now-60*60*24
          # eg v.find_items_by_date('Contacts',to_s,'cf_579')
          
          def find_items_by_date(element,date,extraparam=nil)
                  puts "in query by date  "
                    queryparams=''
                    queryparams=",#{extraparam}" if extraparam!=nil
                    t=Time.parse(date)
                    y=t.strftime('%Y-%m-%d')
                    action_string=ERB::Util.url_encode("select id#{queryparams} from #{element} where createdtime like '#{y}%';")
                #    puts "action string:" +action_string
                    res = http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&query="+action_string)
                    puts "TT RES: #{res["result"]} class: #{res["result"].class}"
                    values=res["result"] if res["success"]==true   #comes back as array
              
                     return res["success"],values

          end
             #extraparams like ',cf_579'
              # one day ago --- Time.now-60*60*24
              # eg v.find_items_by_date_and_key_not_null('Contacts',to_s,'cf_579',"")
       def find_items_by_date_and_key_not_null(element,date,key, extraparam=nil)
                    puts "in query by date and not null  "
                      queryparams=''
                      queryparams=",#{extraparam}" if extraparam!=nil
                      t=Time.parse(date)
                      y=t.strftime('%Y-%m-%d')
                      action_string=ERB::Util.url_encode("select id,#{key}#{queryparams} from #{element} where createdtime like '#{y}%' and #{key}  LIKE '2%' and emailoptout=0;")
                      puts "action string:" +action_string
                      res = http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&query="+action_string)
                      puts "TT RES: #{res["result"]} class: #{res["result"].class}"
                      values=res["result"] if res["success"]==true   #comes back as array
          
                       return res["success"],values

       end
            #extraparams like ',cf_579'
              # one day ago --- Time.now-60*60*24
              # eg v.find_items_by_date_and_key_null('Contacts',to_s,'cf_579',"")
       def find_items_by_date_and_key_null(element,date,key, extraparam=nil)
         # NEED TO ADD QUERY SIZE CAPABILIIES
                    puts "in query by date #{date} and not null  "
                      queryparams=''
                      queryparams=",#{extraparam}" if extraparam!=nil
                      t=Time.parse(date)
                      y=t.strftime('%Y-%m-%d')
                    
                       action_string=ERB::Util.url_encode("select id,#{key}#{queryparams} from #{element} where createdtime like '#{y}%' and #{key} < '0' and emailoptout=0;")
                      puts "action string:" +action_string
                      res = http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&query="+action_string)
                      puts "TT RES: #{res["result"]} class: #{res["result"].class}"
                      values=res["result"] if res["success"]==true   #comes back as array
                   
                       return res["success"],values

       end
def large_find_items_by_date_and_key_null(element,date,key, extraparam=nil)
            # NEED TO ADD QUERY SIZE CAPABILIIES
             
               queryparams=''
               queryparams=",#{extraparam}" if extraparam!=nil
               t=Time.parse(date)
               y=t.strftime('%Y-%m-%d')
               querystring="select id,#{key}#{queryparams} from #{element} where createdtime like '#{y}%' and #{key} < '0' and emailoptout=0"
              countstring="select count(*) from #{element} where createdtime like '#{y}%' and #{key} < '0' and emailoptout=0"
              succ, values =self.large_query(countstring,querystring)
end   
def large_find_items_by_date(element,date, extraparam=nil)
            # NEED TO ADD QUERY SIZE CAPABILIIES
             
               queryparams=''
               queryparams=",#{extraparam}" if extraparam!=nil
               t=Time.parse(date)
               y=t.strftime('%Y-%m-%d')
               querystring="select id#{queryparams} from #{element} where createdtime like '#{y}%'  and emailoptout=0"
              countstring="select count(*) from #{element} where createdtime like '#{y}%'  and emailoptout=0"
              succ, values =self.large_query(countstring,querystring)
end
def large_find_items(element, extraparam=nil)
            # NEED TO ADD QUERY SIZE CAPABILIIES
              
               queryparams=''
               queryparams=",#{extraparam}" if extraparam!=nil
               querystring="select id#{queryparams},emailoptout,email,lastname,firstname from #{element}"
              countstring="select count(*) from #{element}"
              succ, values =self.large_query(countstring,querystring)
end  
def get_campaigns
                    puts "in get campaigns"
                      action_string=ERB::Util.url_encode("select id,campaignname from Campaigns;")
                  
                      res = http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&query="+action_string)
                   #   puts "TT RES: #{res["result"]} class: #{res["result"].class}"
                      values=res["result"] if res["success"]==true   #comes back as array
                      #puts values.inspect
                      # return the account id
                      ## values.each {|v| ticketlist << v['ticket_no'] }
                       return res["success"],values

end
  def check_open_tt_by_contact(contact)
                   puts "in query open tt by contact"
                   action_string=ERB::Util.url_encode("select id,ticket_no from HelpDesk where parent_id = '#{contact}' and ticketstatus like 'Open';")
                    #    puts "action string:" +action_string
                   res = http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&query="+action_string)
                #   puts "TT RES: #{res["result"]} class: #{res["result"].class}"
                   values=res["result"] if res["success"]==true   #comes back as array
                        #puts values.inspect
                        # return the account id
                  ticketlist=[]
                  values.each {|v| ticketlist << v['ticket_no'] }
                  return res["success"],ticketlist
 end        
        def  run_rules(test)
            yield(test)
        end
        def query_product_inventory(options)
          puts "in query product count"
           #&username=#{self.username}&accessKey=#{self.md5}
            # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
            action_string=ERB::Util.url_encode("select id, qtyinstock, productname from Products where productname like '#{options[:productname]}';")
            #puts "action string:" +action_string
            res = http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&query="+action_string)
            # http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&userId=#{self.userid}&query="+action_string)
            puts JSON.pretty_generate(res)
            values=res["result"][0]   #comes back as array
            puts values.inspect
            self.product_id = values["id"]
            self.object_id=self.product_id
            self.qty_in_stock = values["qtyinstock"]
            # NOTE INTEGER VALUES
            self.new_quantity = self.qty_in_stock.to_i + options[:quantity].to_i
            # NEEDS TO RETREIVE OBEJCT
            puts "#{self.product_id}, #{self.qty_in_stock} New quantity should be: #{self.new_quantity}"
            updateobject({'qtyinstock'=> "#{self.new_quantity}","productname"=>"#{options[:productname]}"})
        end
  end
  
end
