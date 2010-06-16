%w{rubygems graboid}.each {|f| require f }

class NingPost
  include Graboid::Entity

  selector 'div.xg_blog .xg_module_body'

  set :title do |elm|
    elm.text.match(/^\s*(.*)$\s*/).captures.first
  end

  set :pub_date, :selector => 'p[class=small]' do |elm| 
    elm.text.match(/on (.* \d+, \d{4})/)[1] 
  end

  set :comment_link, :selector => 'p[class=small]' do |elm|
    elm.css('a').select {|n| n['href'] =~ /comments/ }.first['href'] rescue nil
  end
  
  set :link, :selector => '.title' do |elm|
    elm.css('a').last["href"]
  end

  set :body, :selector => '.title' do |elm|
    # ning's list page only has an excerpt of the body. No biggie,
    # we'll just go grab it.
    show_url = elm.css('a').last["href"]
    Nokogiri::HTML(open(show_url)).css('.postbody').to_html
  end
  
  pager do |doc|
    doc.css('.pagination a').select{|a| a.text =~ /previous/i }.first['href'] rescue nil
  end
  
  before_paginate do
    # clearing empty rows. ning has shit markup 
    # and very few relevant class names.
    self.collection.delete_if {|post| post.css('h3').length == 0 }
    
    # logging for fun
    puts "opening page: #{self.source}"
    puts "collection size: #{self.collection.length}"
    puts "*"*100
  end

end

NingPost.source = 'http://cuwebd.ning.com/profiles/blog/list'
@posts          = NingPost.all(:max_pages => 1)

@posts.each do |post|
  puts "#{post.pub_date} -- #{post.title}"
  puts "*"*100
end

puts "total: #{@posts.length}"
