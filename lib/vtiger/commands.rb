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
    attr_accessor :url, :username, :token, :endpoint_url, :md5, :access_key, :product_id, :qty_in_stock, :session_name, :userid, :new_quantity, :object_id
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
      puts " endpoint: #{self.endpoint_url}"
       t=URI.split(self.endpoint_url.to_s)
       puts "host is: " + t[2]   #FIX THIS.
       ht =Net::HTTP.start(t[2],80)
     
       body_enc=body.url_encode
       puts "attemping post: #{self.endpoint_url}#{operation} body: #{body} body_enc= #{body_enc}"
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
       puts JSON.pretty_generate r
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
       puts JSON.pretty_generate result
    end
      def updateobject(options,values)
        puts "in updateobject"
        object_map= { 'assigned_user_id'=>"#{self.userid}",'id'=>"#{self.object_id}" }.merge values.to_hash
        # 'tsipid'=>"1234"
        tmp=JSON.generate(object_map)
        input_array ={'operation'=>'update','sessionName'=>"#{self.session_name}", 'element'=>tmp} # removed the true
        puts "input array:"  + input_array.to_s   #&username=#{self.username}&accessKey=#{self.md5}
        # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
        result = http_crm_post("operation=update",input_array)
       # self.session_name=result["result"]["sessionName"]
         puts JSON.pretty_generate result
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
       puts JSON.pretty_generate result
    end
    def action(options)
      puts "in action"
    end
      def list_types(options)
        puts "in list types"
         #&username=#{self.username}&accessKey=#{self.md5}
          # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
          result = http_ask_get(self.endpoint_url+"operation=listtypes&sessionName=#{self.session_name}")
          puts JSON.pretty_generate result
      end
      def describe_object(options)
        puts "in describe object"
         #&username=#{self.username}&accessKey=#{self.md5}
          # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
          result = http_ask_get(self.endpoint_url+"operation=describe&sessionName=#{self.session_name}&elementType=#{options[:element_type]}")
          puts JSON.pretty_generate result
      end
      def query(options)
        puts "in describe object"
         #&username=#{self.username}&accessKey=#{self.md5}
          # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
          action_string=ERB::Util.url_encode("#{options[:query]}")
          result = http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&query="+action_string)
          # http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&userId=#{self.userid}&query="+action_string)
          puts JSON.pretty_generate result
      end
        def query_product_inventory(options)
          puts "in query product count"
           #&username=#{self.username}&accessKey=#{self.md5}
            # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
            action_string=ERB::Util.url_encode("select id, qtyinstock, productname from Products where productname like '#{options[:productname]}';")
            puts "action string:" +action_string
            res = http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&query="+action_string)
            # http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&userId=#{self.userid}&query="+action_string)
            puts JSON.pretty_generate res
            values=res["result"][0]   #comes back as array
            puts values.inspect
            self.product_id = values["id"]
            self.object_id=self.product_id
            self.qty_in_stock = values["qtyinstock"]
            # NOTE INTEGER VALUES
            self.new_quantity = self.qty_in_stock.to_i + options[:quantity].to_i
            puts "#{self.product_id}, #{self.qty_in_stock} New quantity should be: #{self.new_quantity}"
            updateobject(options,{'qtyinstock'=> "#{self.new_quantity}","productname"=>"#{options[:productname]}"})
        end
  end
  
end
