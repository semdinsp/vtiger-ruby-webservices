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
  def test_bad_login
     cmd = Vtiger::Commands.new()
     @options[:username]='test'
     challenge=cmd.challenge(@options)
     login=cmd.login(@options)
     assert challenge,"challenge is false "
     assert !login,"login should not succeed"
  end
  def test_add_lead
     cmd = Vtiger::Commands.new()
     challenge=cmd.challenge(@options)
     login=cmd.login(@options)
     hv={}
     hv[:firstname]='test'
     lead=cmd.addlead(@options,"testlastname","testco",hv)
     assert challenge,"challenge is false "
     assert login,"login should succeed"
     assert lead,"lead should succeed"
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
