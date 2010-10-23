require File.dirname(__FILE__) + '/test_helper.rb'

class TestVtiger < Test::Unit::TestCase

  def setup
    @options={}
    @options[:url]='democrm.estormtech.com'   
    @options[:key]='xBY6leZ5kZHQm2Y'
    @options[:username]="admin"
    @options[:element_type]="Contacts"  
  end
  
  def test_login
     cmd = Vtiger::Commands.new()
     challenge=cmd.challenge(@options)
     login=cmd.login(@options)
     assert challenge,"challenge is false"
     assert login,"login is false"
  end
def test_get_campaigns
   cmd = Vtiger::Commands.new()
   @options[:username]='admin'
   challenge=cmd.challenge(@options)
   login=cmd.login(@options)
   success,values=cmd.get_campaigns()
   assert challenge,"challenge is false "
   assert login,"login should  succeed"
   assert success,"find campaigns should success" 
   puts "CAMPAIGNS #{values}"
end
def test_get_contacts_from_campaigns
   cmd = Vtiger::Commands.new()
   @options[:username]='admin'
   challenge=cmd.challenge(@options)
   login=cmd.login(@options)
   success,values=cmd.get_campaigns()
   require 'test_secret'
   cmd.accessdatabase(VTIGERDBHOST, VTIGERDB, VTIGERDBUSER,VTIGERDBPASSWD)
end
  def test_api_login
    Vtiger::Api.api_settings = {
         :username => 'admin',
         :key => 'xBY6leZ5kZHQm2Y',
         :url => 'democrm.estormtech.com',
         :element_type => 'Contacts'
       }
     cmd = Vtiger::Commands.new()
     challenge=cmd.challenge({})
     login=cmd.login({})
     assert challenge,"challenge is false"
     assert login,"login is false"
  end
  def test_api_login2
    Vtiger::Api.api_settings = {
         :username => 'admin',
         :key => 'xBY6leZ5kZHQm2Y',
         :url => 'democrm.estormtech.com',
         :element_type => 'Contacts'
       }
     cmd = Vtiger::Commands.new()
     options={}
     options[:username]='admin'
     challenge=cmd.challenge(options)
     login=cmd.login(options)
     assert challenge,"challenge is false"
     assert login,"login is false"
  end
 
  def test_find_or_add_contact
       cmd = Vtiger::Commands.new()
       @options[:username]='admin'
       challenge=cmd.challenge(@options)
       login=cmd.login(@options)
       success,id=cmd.find_contact_by_email_or_add(@options,'sproule','scott.sproule@gmail.com',{})
       assert challenge,"challenge is false "
       assert login,"login should  succeed"
       assert success,"find contact should success"
       assert id=='4x173', "id is #{id}"
       puts "id is #{id}"

    end
  def test_bad_login
     cmd = Vtiger::Commands.new()
     @options[:username]='test'
     challenge=cmd.challenge(@options)
     login=cmd.login(@options)
     assert challenge,"challenge is false "
     assert !login,"login should not succeed"
  end
  def test_query_contact
      cmd = Vtiger::Commands.new()
      @options[:username]='admin'
      challenge=cmd.challenge(@options)
      login=cmd.login(@options)
      success,id=cmd.query_element_by_email("scott.sproule@gmail.com","Contacts")
      assert challenge,"challenge is false "
      assert login,"login should  succeed"
      assert success,"find contact should success"
      puts "id is #{id}"
      
   end
  def test_add_lead
     cmd = Vtiger::Commands.new()
     challenge=cmd.challenge(@options)
     login=cmd.login(@options)
     hv={}
     hv[:firstname]='test'
     success,id=cmd.addlead(@options,"testlastname","testco",hv)
     assert challenge,"challenge is false "
     assert login,"login should succeed"
     assert success,"lead should succeed"
     puts "id is #{id}"
  end
  def test_add_contact
      cmd = Vtiger::Commands.new()
      challenge=cmd.challenge(@options)
      login=cmd.login(@options)
      hv={}
      hv[:firstname]='test'
      success,id=cmd.add_contact(@options,"testlastname","scott.sproule@gmail.com",hv)
      assert challenge,"challenge is false "
      assert login,"login should succeed"
      assert success,"add should succeed"
      puts "id is #{id}"
   end
   def test_update_contact
     puts "in update contact"
       cmd = Vtiger::Commands.new()
       challenge=cmd.challenge(@options)
       login=cmd.login(@options)
       hv={}
     
       success,id=cmd.query_element_by_email("scott.sproule@gmail.com","Contacts")
        values=cmd.retrieve_object(id)
        values['firstname']='testupdtae'
        upd= cmd.updateobject(values)
       assert challenge,"challenge is false "
       assert login,"login should succeed"
       assert success,"add should succeed"
        assert upd,"update should succeed"
       puts "id is #{id}"
    end
  
  def test_add_trouble_ticket
     cmd = Vtiger::Commands.new()
     challenge=cmd.challenge(@options)
     login=cmd.login(@options)
     hv={}
    # hv[:firstname]='test'
     tt,ticketnum=cmd.add_trouble_ticket(@options,"Open","testing title",hv)
     
     puts "trouble ticket is #{tt} ticket number is #{ticketnum}"
     assert challenge,"challenge is false "
     assert login,"login should succeed"
     assert tt,"trouble ticket should succeed"
  end
  def test_rule_block
      cmd = Vtiger::Commands.new()
      challenge=cmd.challenge(@options)
      login=cmd.login(@options)
      res=cmd.run_rules("hello") {|t|   puts "RULE BLOCK #{t} what is self? #{self.inspect} class #{self.class}"
                                       return t=="hello"}
       assert challenge,"challenge is false "
       assert login,"login should succeed"
       assert res,"rules should succeed"
  end
  def test_find_open_trouble_ticket_by_contacts
     cmd = Vtiger::Commands.new()
     challenge=cmd.challenge(@options)
     login=cmd.login(@options)
     hv={}
    # hv[:firstname]='test'
     success,contact_id=cmd.query_element_by_email("scott.sproule@gmail.com","Contacts")
     tt,ticketlist=cmd.check_open_tt_by_contact(contact_id) if success  
     puts "trouble ticket is #{tt} ticket number is #{ticketlist}"
     assert challenge,"challenge is false "
     assert success,"could not find contact id with email scott.sproule@gmail.com  "
     assert login,"login should succeed"
     assert tt,"open trouble ticket findersshould succeed"
     puts "tickelist is #{ticketlist}"
  end
  def test_find_trouble_ticket_by_contacts
     cmd = Vtiger::Commands.new()
     challenge=cmd.challenge(@options)
     login=cmd.login(@options)
     hv={}
    # hv[:firstname]='test'
     success,contact_id=cmd.query_element_by_email("scott.sproule@gmail.com","Contacts")
     tt,ticketlist=cmd.find_tt_by_contact(contact_id) if success
     
     puts "trouble ticket is #{tt} ticket number is #{ticketlist}"
     assert challenge,"challenge is false "
     assert success,"could not find contact id with email scott.sproule@gmail.com  "
     assert login,"login should succeed"
     assert tt,"trouble ticket findersshould succeed"
     puts "tickelist is #{ticketlist}"
  end
  def test_find_account_by_email
     puts "in find account by email"
     cmd = Vtiger::Commands.new()
     challenge=cmd.challenge(@options)
     login=cmd.login(@options)
     hv={}
    # hv[:firstname]='test'
     success,account_id=cmd.query_element_by_email("scott.sproule@gmail.com","Accounts")
     assert challenge,"challenge is false "
     assert success,"could not find account id with email scott.sproule@gmail.com  "
     assert login,"login should succeed"
     puts "ACCOUNT ID IS  #{account_id}"
     assert account_id=='3x269',"account id should be #{account_id}"
    # puts "tickelist is #{ticketlist}"
  end
  def test_describe_object
      cmd = Vtiger::Commands.new()
      challenge=cmd.challenge(@options)
      login=cmd.login(@options)
        @options[:element_type]="Leads"  
      cmd.describe_object(@options)
      assert challenge,"challenge is false "
      assert login,"login should succeed"
     
   end
end
