require 'net/http'
#require 'yajl'
require 'yajl'
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
  class Base
     attr_accessor :md5,:token, :endpoint_url, :access_key, :session_name, :url, :username,  :userid
     
     def challenge(options)

       #puts "in challenge"
       self.url=options[:url] || Vtiger::Api.api_settings[:url]
       self.username = options[:username]|| Vtiger::Api.api_settings[:username]
       self.access_key = options[:key] || Vtiger::Api.api_settings[:key]
       self.endpoint_url="http://#{self.url}/webservice.php?"
       operation = "operation=getchallenge&username=#{self.username}"; 
        #puts "challenge: " + self.endpoint_url + operation
        r=http_ask_get(self.endpoint_url+operation)
       # puts JSON.pretty_generate(r)
       # puts "success is: " + r["success"].to_s   #==true
        self.token = r["result"]["token"] #if r["success"]==true

        #puts "token is: " + self.token
         create_digest
        #puts "digest is: #{self.md5} token #{self.token}" 
        self.token!=nil
     end
     def create_digest
        #access key from my_preferences page of vtiger
        digest_string="#{self.token}#{self.access_key}"
        self.md5=Digest::MD5.hexdigest(digest_string)
        puts "#{self.url}: string #{digest_string} results in digest: "+self.md5 + " access key: "+ self.access_key + " token: " + self.token
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
           resp=ht.post(self.endpoint_url+operation,body_enc,response_header)

           # p response.body.to_s
           self.json_parse resp.body
           # r=JSON.parse response.body
          #  r
        end
        def http_ask_get(input_url)
         # puts "about to HTTP.get on '#{input_url}'"
         # url=ERB::Util.url_encode(input_url)
         # resp= Net::HTTP.get(URI.parse(url))
          url = URI.parse(input_url)
         # puts "inspect url: " + url.inspect
              req = Net::HTTP::Get.new("#{url.path}?#{url.query}")
              resp = Net::HTTP.start(url.host, url.port) {|http|
            #    puts "url path is #{url.path}"
                http.request(req)
              }
           # puts "HTTP_ASK_GET" + resp.body.to_s


         # puts "resp: " + resp 
          self.json_parse resp.body
       #   r
        end
        def add_object(object_map,hashv,element)
          object_map=object_map.merge hashv
          # 'tsipid'=>"1234"
          tmp=self.json_please(object_map)
          input_array ={'operation'=>'create','elementType'=>"#{element}",'sessionName'=>"#{self.session_name}", 'element'=>tmp} # removed the true
          puts "input array:"  + input_array.to_s   #&username=#{self.username}&accessKey=#{self.md5}
          # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
          result = http_crm_post("operation=create",input_array)
         # self.session_name=result["result"]["sessionName"]
          # puts JSON.pretty_generate(result)
          success=result['success']
          id =result["result"]['id'] if success
          return success,id
        end
        def login(options)
         # puts "in login"
          input_array ={'operation'=>'login', 'username'=>self.username, 'accessKey'=>self.md5} # removed the true
          puts "input array:"  + input_array.to_s   #&username=#{self.username}&accessKey=#{self.md5}
          # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
          result = http_crm_post("operation=login",input_array)
          self.session_name=result["result"]["sessionName"] if result["result"]!=nil
          self.userid = result["result"]["userId"] if result["result"]!=nil
          puts "session name is: #{self.session_name} userid #{self.userid}"
          self.userid!=nil
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
        puts "in query object"
         #&username=#{self.username}&accessKey=#{self.md5}
          # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
          action_string=ERB::Util.url_encode("#{options[:query]}")
          result = http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&query="+action_string)
          # http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&userId=#{self.userid}&query="+action_string)
       #   puts JSON.pretty_generate(result)
end
def describe_object(options)
          puts "in describe object"
           #&username=#{self.username}&accessKey=#{self.md5}
            # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
            result = http_ask_get(self.endpoint_url+"operation=describe&sessionName=#{self.session_name}&elementType=#{options[:element_type]}")
           # puts JSON.pretty_generate(result)
         
          puts "#{result.inspect}"    #scott  tmp=JSON.generate(object_map)
           
end
def addobject(options)
          puts "in addobject"
          object_map= { 'assigned_user_id'=>"#{self.userid}",'lastname'=>"#{options[:contact]}",'cf_554'=>"1234"}
          # 'tsipid'=>"1234"
          tmp=self.json_please(object_map)
          input_array ={'operation'=>'create','elementType'=>"#{options[:element_type]}",'sessionName'=>"#{self.session_name}", 'element'=>tmp} # removed the true
          puts "input array:"  + input_array.to_s   #&username=#{self.username}&accessKey=#{self.md5}
          # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
          result = http_crm_post("operation=create",input_array)
         # self.session_name=result["result"]["sessionName"]
         #  puts JSON.pretty_generate(result)
end
def json_parse(incoming)
   json = StringIO.new(incoming)
   parser = Yajl::Parser.new
   hash = parser.parse(json)
end
def json_please(object_map)
   if defined? RAILS_ENV
       #puts "in JSON code rails env: #{RAILS_ENV}"
        tmp=object_map.to_json
    else
      puts "rails env is not defined"
   #   json = StringIO.new()
      str = Yajl::Encoder.encode(object_map)
      
   #    parser = Yajl::Parser.new
    #   tmp = parser.parse(object_map.to_s)
        #   object_map.to_json    #  can remove eventually this if statements
      
     # tmp=YAJL.generate(object_map)   #scott  tmp=JSON.generate(object_map)
    end
    str
end
def updateobject(values)
            #puts "in updateobject"
            object_map= { 'assigned_user_id'=>"#{self.userid}",'id'=>"#{self.object_id}" }.merge values.to_hash
            # 'tsipid'=>"1234"
            tmp=self.json_please(object_map)
            input_array ={'operation'=>'update','sessionName'=>"#{self.session_name}", 'element'=>tmp} # removed the true
            #puts "input array:"  + input_array.to_s   #&username=#{self.username}&accessKey=#{self.md5}
            # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
            result = http_crm_post("operation=update",input_array)
           # self.session_name=result["result"]["sessionName"]
           #  puts JSON.pretty_generate(result)
end
  end #clase base
end #moduble