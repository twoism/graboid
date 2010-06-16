dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require File.join(dir, 'graboid')

class ActiveRainPost
  include Graboid::Entity

  selector '.blog_entry_wrapper'

  set :title, :selector => 'h2 a'
  set :pub_date, :selector => '.blog_entry' do |elm|
    # awesome, the pub date is not contained within 
    # the .blog_entry_wrapper fragment.
    begin
      entry_id = elm['id'].gsub('blog_entry_','')
      date_text = self.doc.css("#divbei#{entry_id} td").select{|td| td.text =~ /posted by/i }.first.text
      date_text.match(/(\d{2}\/\d{2}\/\d{4})/).captures.first 
    rescue
      ""
    end
  end
  set :body, :selector => 'div' do |elm|
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
@posts  = ActiveRainPost.all(:max_pages => 1)

@posts.each do |post|
  puts "#{post.pub_date}"
  puts "*"*100
end

puts "total: #{@posts.length}"
