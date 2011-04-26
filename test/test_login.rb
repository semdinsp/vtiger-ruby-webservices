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
  def test_factory
    api ={
           :username => 'admin',
         :key => 'xBY6leZ5kZHQm2Y',
          # :username => 'admin',
          # :key => 'ISGRkVGyEYunzQlD',
           :url => 'democrm.estormtech.com',
         }
     cmd = Vtiger::Commands.vtiger_factory(api)
     
     assert cmd.class==Vtiger::Commands,"class is wrong "
    # assert login,"login is false"
  end
  
   def test_accountlist
      setup
       cmd = Vtiger::Commands.new()
       challenge=cmd.challenge(@options)
       puts "challenge is: #{challenge}"
       login=cmd.login(@options)
       puts "login is #{login}"
       suc,list=cmd.query_accountlist_by_name('esto')
       assert suc,"success should be true"
       puts "list is #{list}"
    end
    def test_accountlist2
        setup
         cmd = Vtiger::Commands.new()
         challenge=cmd.challenge(@options)
         puts "challenge is: #{challenge}"
         login=cmd.login(@options)
         puts "login is #{login}"
         suc,list=cmd.query_accountlist_by_name('vtig')
         assert suc,"success should be true"
         puts "list is #{list}"
      end
  
end