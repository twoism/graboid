%w{rubygems nokogiri open-uri ostruct}.each { |f| require f }

dir = Pathname(__FILE__).dirname.expand_path

require dir + 'graboid/entity'
require dir + 'graboid/scraper'

class String
  def underscore
    self.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end
end

module Graboid
  extend self
  
  def user_agent
    @user_agent ||= 'Foo'
  end
  
  def user_agent=(agent)
    @user_agent = agent
  end
end
