require 'net/http'
require 'json'
#require 'digest/md5'
require 'erb'
 

module Vtiger
  class Commands < Vtiger::Base
    attr_accessor  :product_id, :qty_in_stock, :new_quantity, :object_id, :account_name
   
   
    
     # scott was: def updateobject(options,values)
 # add a lead with ln last name, co company, and hashv a hash of other values you want to set    
    def addlead(options,ln,co,hashv)
      puts "in addobject"
      object_map= { 'assigned_user_id'=>"#{self.userid}",'lastname'=>"#{ln}", 'company'=>"#{co}"}
      object_map=object_map.merge hashv
      # 'tsipid'=>"1234"
      tmp=self.json_please(object_map)
      input_array ={'operation'=>'create','elementType'=>"Leads",'sessionName'=>"#{self.session_name}", 'element'=>tmp} # removed the true
      puts "input array:"  + input_array.to_s   #&username=#{self.username}&accessKey=#{self.md5}
      # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
      result = http_crm_post("operation=create",input_array)
     # self.session_name=result["result"]["sessionName"]
      # puts JSON.pretty_generate(result)
      result["success"]
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
            puts "action string:" +action_string
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
        def query_product_inventory(options)
          puts "in query product count"
           #&username=#{self.username}&accessKey=#{self.md5}
            # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
            action_string=ERB::Util.url_encode("select id, qtyinstock, productname from Products where productname like '#{options[:productname]}';")
            puts "action string:" +action_string
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
