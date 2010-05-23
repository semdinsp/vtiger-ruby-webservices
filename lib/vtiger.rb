$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
Dir[File.join(File.dirname(__FILE__), 'vtiger/**/*.rb')].sort.each { |lib| require lib }
module Vtiger
  VERSION = '0.3.4'
end