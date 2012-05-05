require 'net/http'
#require 'yajl'
require 'rubygems'
gem 'yajl-ruby'
require 'yajl'
require 'digest/md5'
require 'erb'
#gem 'activerecord'
require 'active_record'
class Hash  
  def url_encode  
    to_a.map do |name_value|  
      name_value.map { |e| URI.encode e.to_s }.join '='  
     end.join '&'  
   end  
 end
class CampaignList < ActiveRecord::Base
  
  def self.scott_connect(dbhost, dbname, dbuser,dbpasswd)
    CampaignList.set_table_name('vtiger_campaigncontrel')
    @myconnection =CampaignList.establish_connection(
        :adapter  => "mysql",
        :host     => dbhost,
        :username => dbuser,
        :password => dbpasswd,
        :database => dbname
      )
  end
  def self.scott_connect2(dbhost, dbname, dbuser,dbpasswd)
    # CampaignList.set_table_name('vtiger_campaigncontrel')
     @myconnection =CampaignList.establish_connection(
         :adapter  => "mysql",
         :host     => dbhost,
         :username => dbuser,
         :password => dbpasswd,
         :database => dbname
       )
   end
  def self.convert(mysql_res)
    rows=[]
    mysql_res.each_hash { |h| rows << h
     # puts "h is #{h} #{h.inspect} #{h.class}"
      }
    rows
  end
  def self.find_contacts_by_campaign(id)
    mysql_results=CampaignList.connection.execute("select vtiger_contactdetails.email, vtiger_contactdetails.firstname, vtiger_contactdetails.lastname,  vtiger_campaigncontrel.campaignid from vtiger_contactdetails left join vtiger_campaigncontrel on vtiger_contactdetails.contactid=vtiger_campaigncontrel.contactid where vtiger_campaigncontrel.campaignid=#{id} and emailoptout=0;")
  CampaignList.convert(mysql_results)
  end
  def self.find_leads_by_campaign(id)
    mysql_results=CampaignList.connection.execute("select vtiger_leaddetails.email, vtiger_leaddetails.firstname, vtiger_leaddetails.lastname,  vtiger_campaignleadrel.campaignid from vtiger_leaddetails left join vtiger_campaignleadrel on vtiger_leaddetails.leadid=vtiger_campaignleadrel.leadid where vtiger_campaignleadrel.campaignid=#{id};")
  CampaignList.convert(mysql_results)
  end
  def self.find_accounts_by_campaign(id)
    mysql_results=CampaignList.connection.execute("select vtiger_account.email1 as 'email', vtiger_account.accountname,   vtiger_campaignaccountrel.campaignid from vtiger_account left join vtiger_campaignaccountrel on vtiger_account.accountid=vtiger_campaignaccountrel.accountid where vtiger_campaignaccountrel.campaignid=#{id} and emailoptout=0;;")
  CampaignList.convert(mysql_results)
  end
  def self.find_contacts_by_customfield(field,value,extra='') # ",customfield as latest_receipt"
    puts "field: #{field} value #{value}"
    mysql_results=CampaignList.connection.execute("select vtiger_contactdetails.contactid as 'id',vtiger_contactdetails.email as 'email'#{extra},#{field} as 'tsipid' from  vtiger_contactdetails left join vtiger_contactscf on vtiger_contactdetails.contactid=vtiger_contactscf.contactid  where #{field} like '#{value}%';")
  #  puts "after campaign #{mysql_results}"
  CampaignList.convert(mysql_results)
  end
  def self.find_contacts_by_email_and_keynull(key,value)
    puts "key: #{key} value #{value}"
    mysql_results=CampaignList.connection.execute("select vtiger_contactdetails.contactid as 'id',vtiger_contactdetails.email as 'email', #{key} as 'tsipid' from  vtiger_contactdetails left join vtiger_contactscf on vtiger_contactdetails.contactid=vtiger_contactscf.contactid  where vtiger_contactdetails.email like '#{value}%' and  #{key} like '';")
  #  puts "after campaign #{mysql_results}"
  CampaignList.convert(mysql_results)
  end
end
module Vtiger
  class Base
     attr_accessor :md5,:token, :endpoint_url, :access_key, :session_name, :url, :username,  :userid, :campaigndb
     
def challenge(options)
    #   puts "in challenge"
       self.url=options[:url] || Vtiger::Api.api_settings[:url]
       self.username = options[:username]|| Vtiger::Api.api_settings[:username]
       self.access_key = options[:key] || Vtiger::Api.api_settings[:key]
       self.endpoint_url="http://#{self.url}/webservice.php?"
       operation = "operation=getchallenge&username=#{self.username}"; 
        #puts "challenge: " + self.endpoint_url + operation
        r=http_ask_get(self.endpoint_url+operation)
        self.token = r["result"]["token"] #if r["success"]==true

         create_digest
      #  puts "digest is: #{self.md5} token #{self.token}" 
        self.token!=nil
end
     def create_digest
        #access key from my_preferences page of vtiger
        digest_string="#{self.token}#{self.access_key}"
        self.md5=Digest::MD5.hexdigest(digest_string)
       # puts "#{self.url}: string #{digest_string} results in digest: "+self.md5 + " access key: "+ self.access_key + " token: " + self.token
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
        def large_query(countquery, query)
             qaction_string=ERB::Util.url_encode("#{countquery};")
            res=http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&query="+qaction_string)
          #    puts "action string:" +action_string
          puts "success: #{res['success']} res class #{res} count #{res['result']}"
              temp=res['result'][0]    
              puts "  temp: #{temp} class #{temp.class} inspect #{temp.inspect}"
              count=temp['count'].to_i
              s=count/100
              puts "s is #{s}"
              output=[]
              finalres=true
              0.upto(s) { |i| puts i 
                  action_string=ERB::Util.url_encode("#{query} limit #{i*100},100;")
                  puts "COUNT :#{i} #{action_string}"
                  res = http_ask_get(self.endpoint_url+"operation=query&sessionName=#{self.session_name}&query="+action_string)
                  values=res["result"] if res["success"]==true
                  finalres=finalres && res["success"]
                  values.each {|i|  output << i }
                 # output << values
                }  
             return finalres, output
        end
        def add_object(object_map,hashv,element)
          object_map=object_map.merge hashv
          # 'tsipid'=>"1234"
          tmp=self.json_please(object_map)
          input_array ={'operation'=>'create','elementType'=>"#{element}",'sessionName'=>"#{self.session_name}", 'element'=>tmp} # removed the true
         # puts "input array:"  + input_array.to_s   #&username=#{self.username}&accessKey=#{self.md5}
          # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
          result = http_crm_post("operation=create",input_array)
        #  puts "ADD OBJEcT #{result.inspect}"
         # self.session_name=result["result"]["sessionName"]
          # puts JSON.pretty_generate(result)
          success=result['success']
          id =result["result"]['id'] if success
          return success,id
        end
        def login(options)
         # puts "in login"
          input_array ={'operation'=>'login', 'username'=>self.username, 'accessKey'=>self.md5} # removed the true
          #puts "input array:"  + input_array.to_s   #&username=#{self.username}&accessKey=#{self.md5}
          # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
          result = http_crm_post("operation=login",input_array)
          self.session_name=result["result"]["sessionName"] if result["result"]!=nil
          self.userid = result["result"]["userId"] if result["result"]!=nil
        #  puts "session name is: #{self.session_name} userid #{self.userid}"
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
         # puts "input array:"  + input_array.to_s   #&username=#{self.username}&accessKey=#{self.md5}
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
        str=object_map.to_json
    else
     # puts "rails env is not defined"
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
           # object_map= { 'assigned_user_id'=>"#{self.userid}"}.merge  values.to_hash
           object_map= {'id'=>"#{self.object_id}" }.merge values.to_hash
            #object_map['assigned_user_id']="#{self.userid}"
            # 'tsipid'=>"1234"
           # puts "object map is #{object_map.to_s}"
            tmp=self.json_please(object_map)
            input_array ={'operation'=>'update','sessionName'=>"#{self.session_name}", 'element'=>tmp} # removed the true
         #   puts "input array:"  + input_array.to_s   #&username=#{self.username}&accessKey=#{self.md5}
            # scott not working -- JSON.generate(input_array,{'array_nl'=>'true'})
            result = http_crm_post("operation=update",input_array)
           # self.session_name=result["result"]["sessionName"]
           #  puts JSON.pretty_generate(result)
end
def accessdatabase(dbhost, dbname, dbuser,dbpasswd)
  #select vtiger_contactdetails.email, vtiger_contactdetails.firstname, vtiger_contactdetails.lastname,  vtiger_campaigncontrel.campaignid from vtiger_contactdetails left join vtiger_campaigncontrel on vtiger_contactdetails.contactid=vtiger_campaigncontrel.contactid where vtiger_campaigncontrel.campaignid='14' and emailoptout=0;
  #self.campaigndb=CampaignList.new
  CampaignList.scott_connect(dbhost, dbname, dbuser,dbpasswd)
  
  
end
def accessdatabase2(dbhost, dbname, dbuser,dbpasswd)
  #select vtiger_contactdetails.email, vtiger_contactdetails.firstname, vtiger_contactdetails.lastname,  vtiger_campaigncontrel.campaignid from vtiger_contactdetails left join vtiger_campaigncontrel on vtiger_contactdetails.contactid=vtiger_campaigncontrel.contactid where vtiger_campaigncontrel.campaignid='14' and emailoptout=0;
  #self.campaigndb=CampaignList.new
  CampaignList.scott_connect2(dbhost, dbname, dbuser,dbpasswd)
  
  
end
def get_list_from_campaign(campaignid,type)
  #self.campaigndb.find_contacts_by_campaign(self.campaigndb,campaignid)
  list=CampaignList.find_leads_by_campaign(campaignid) if type=='Leads'
  list=CampaignList.find_accounts_by_campaign(campaignid) if type=='Accounts'
  list=CampaignList.find_contacts_by_campaign(campaignid) if type=='Contacts'
  list
end
def get_contacts_from_campaign(campaignid)
  #self.campaigndb.find_contacts_by_campaign(self.campaigndb,campaignid)
  CampaignList.find_contacts_by_campaign(campaignid)
  
end
def get_contacts_by_cf(field,value,extra='')
  #self.campaigndb.find_contacts_by_campaign(self.campaigndb,campaignid)
  CampaignList.find_contacts_by_customfield(field,value,extra)
end
def get_contacts_by_email_and_keynull(field,value)
  #self.campaigndb.find_contacts_by_campaign(self.campaigndb,campaignid)
  CampaignList.find_contacts_by_email_and_keynull(field,value)
end
  end #clase base
end #moduble