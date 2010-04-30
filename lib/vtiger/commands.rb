require 'net/http'
require 'json'
require 'digest/md5'
require 'erb'
 class Hash  
  def url_encode  
    to_a.map do |name_value|  
      name_value.map { |e| CGI.escape e.to_s }.join '='  
     end.join '&'  
   end  
 end

module Vtiger
  class Commands
    attr_accessor :url, :username, :token, :endpoint_url, :md5, :access_key, :product_id, :qty_in_stock, :session_name, :userid, :new_quantity, :object_id, :account_name
    def process_response
    end
    def create_digest
      #access key from my_preferences page of vtiger
      digest_string="#{self.token}#{self.access_key}"
      self.md5=Digest::MD5.hexdigest(digest_string)
      puts "string #{digest_string} results in digest: "+self.md5 + " access key: "+ self.access_key + " token: " + self.token
    end
    def http_crm_post(operation, body)
      response = nil
      response_header = {"Content-type" => "application/x-www-form-urlencoded"}
      #puts " endpoint: #{self.endpoint_url}"
       t=URI.split(self.endpoint_url.to_s)
      # puts "host is: " + t[2]   #FIX THIS.
       ht =Net::HTTP.start(t[2],80)
     
       body_enc=body.url_encode
      # puts "attemping post: #{self.endpoint_url}#{operation} body: #{body} body_enc= #{body_enc}"
       response=ht.post(self.endpoint_url+operation,body_enc,response_header)
        
        p response.body.to_s
        r=JSON.parse response.body
        r
    end
    def http_ask_get(input_url)
      puts "about to HTTP.get on '#{input_url}'"
     # url=ERB::Util.url_encode(input_url)
     # resp= Net::HTTP.get(URI.parse(url))
      url = URI.parse(input_url)
     # puts "inspect url: " + url.inspect
          req = Net::HTTP::Get.new("#{url.path}?#{url.query}")
          resp = Net::HTTP.start(url.host, url.port) {|http|
        #    puts "url path is #{url.path}"
            http.request(req)
          }
      #   puts resp.body
      
      
     # puts "resp: " + resp 
      r=JSON.parse resp.body
      r
    end
    def challenge(options)
      
      puts "in challenge"
      self.url=options[:url]
      self.username = options[:username]
      self.access_key = options[:key]
      self.endpoint_url="http://#{self.url}/webservice.php?"
      operation = "operation=getchallenge&username=#{self.username}"; 
       puts "challenge: " + self.endpoint_url + operation
       r=http_ask_get(self.endpoint_url+operation)
      # puts JSON.pretty_generate(r)
       puts "success is: " + r["success"].to_s   #==true
       self.token = r["result"]["token"] #if r["success"]==true
     
       puts "token is: " + self.token
        create_digest
       puts "digest is: " + self.md5
    end
    def login(options)
      puts "in login"
      input_array ={'operation'=>'login', 'username'=>self.username, 'accessKey'=>self.md5} # removed the true
      puts "input array:"  + input_array.to_s   #&username=#{self.username}&accessKey=#{self.md5}
      # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
      result = http_crm_post("operation=login",input_array)
      self.session_name=result["result"]["sessionName"]
      self.userid = result["result"]["userId"]
      puts "session name is: #{self.session_name} userid #{self.userid}"
    end
    def addobject(options)
      puts "in addobject"
      object_map= { 'assigned_user_id'=>"#{self.userid}",'lastname'=>"#{options[:contact]}",'cf_554'=>"1234"}
      # 'tsipid'=>"1234"
      tmp=JSON.generate(object_map)
      input_array ={'operation'=>'create','elementType'=>"#{options[:element_type]}",'sessionName'=>"#{self.session_name}", 'element'=>tmp} # removed the true
      puts "input array:"  + input_array.to_s   #&username=#{self.username}&accessKey=#{self.md5}
      # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
      result = http_crm_post("operation=create",input_array)
     # self.session_name=result["result"]["sessionName"]
     #  puts JSON.pretty_generate(result)
    end
     # scott was: def updateobject(options,values)
      def updateobject(values)
        #puts "in updateobject"
        object_map= { 'assigned_user_id'=>"#{self.userid}",'id'=>"#{self.object_id}" }.merge values.to_hash
        # 'tsipid'=>"1234"
        if defined? RAILS_ENV
           puts "in JSON code rails env: #{RAILS_ENV}"
            tmp=object_map.to_json
        else
          puts "rails env is not definted"
          tmp=JSON.fast_generate(object_map)   #scott  tmp=JSON.generate(object_map)
        end
        input_array ={'operation'=>'update','sessionName'=>"#{self.session_name}", 'element'=>tmp} # removed the true
        #puts "input array:"  + input_array.to_s   #&username=#{self.username}&accessKey=#{self.md5}
        # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
        result = http_crm_post("operation=update",input_array)
       # self.session_name=result["result"]["sessionName"]
       #  puts JSON.pretty_generate(result)
      end
    def addlead(options)
      puts "in addobject"
      object_map= { 'assigned_user_id'=>"#{self.userid}",'lastname'=>"#{options[:contact]}",'leadstatus'=>"Cold", 'company'=>"testcompany"}
      # 'tsipid'=>"1234"
      tmp=JSON.generate(object_map)
      input_array ={'operation'=>'create','elementType'=>"#{options[:element_type]}",'sessionName'=>"#{self.session_name}", 'element'=>tmp} # removed the true
      puts "input array:"  + input_array.to_s   #&username=#{self.username}&accessKey=#{self.md5}
      # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
      result = http_crm_post("operation=create",input_array)
     # self.session_name=result["result"]["sessionName"]
      # puts JSON.pretty_generate(result)
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
      def describe_object(options)
        puts "in describe object"
         #&username=#{self.username}&accessKey=#{self.md5}
          # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
          result = http_ask_get(self.endpoint_url+"operation=describe&sessionName=#{self.session_name}&elementType=#{options[:element_type]}")
         # puts JSON.pretty_generate(result)
         if defined? RAILS_ENV
            puts "in JSON code rails env: #{RAILS_ENV}"
             puts object_map.to_json
         else
           puts "rails env is not definted"
           puts JSON.pretty_generate(result)    #scott  tmp=JSON.generate(object_map)
         end
      end
         def retrieve_object(objid)
            puts "in retrieve object"
             #&username=#{self.username}&accessKey=#{self.md5}
              # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
              result = http_ask_get(self.endpoint_url+"operation=retrieve&sessionName=#{self.session_name}&id=#{objid}")
           #   puts JSON.pretty_generate(result)
               values=result["result"]
               values
          end
      def query(options)
        puts "in describe object"
         #&username=#{self.username}&accessKey=#{self.md5}
          # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
          action_string=ERB::Util.url_encode("#{options[:query]}")
          result = http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&query="+action_string)
          # http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&userId=#{self.userid}&query="+action_string)
       #   puts JSON.pretty_generate(result)
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
