%w{rubygems nokogiri open-uri active_support}.each { |f| require f }

dir = Pathname(__FILE__).dirname.expand_path

require dir + 'graboid/entity'


module Graboid
end