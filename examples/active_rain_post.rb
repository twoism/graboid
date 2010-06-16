dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require File.join(dir, 'graboid')

class ActiveRainPost
  include Graboid::Entity

  root   '.blog_entry'

  field :title, :selector => 'h2'

  field :body, :selector => 'div' do |elm|
    elm.css('p').collect(&:to_html)
  end
  
  pager do |doc|
    "http://activerain.com" + doc.css('.pagination a').select{|a| a.text =~ /Next/i }.first['href'] rescue nil
  end
  
  before_paginate do
    # logging for fun
    puts "opening page: #{self.source}"
    puts "collection size: #{self.collection.length}"
    puts "*"*100
  end

end

ActiveRainPost.source = 'http://activerain.com/blogs/elizabethweintraub'
@posts  = ActiveRainPost.all

@posts.each do |post|
  puts "#{post.title}"
  puts "*"*100
end

puts "total: #{@posts.length}"
