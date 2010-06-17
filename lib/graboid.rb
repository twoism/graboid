%w{rubygems nokogiri open-uri active_support ostruct}.each { |f| require f }

dir = Pathname(__FILE__).dirname.expand_path

require dir + 'graboid/entity'
require dir + 'graboid/scraper'


module Graboid
end