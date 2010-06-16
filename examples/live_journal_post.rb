dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require File.join(dir, 'graboid')

class LiveJournalPost
  include Graboid::Entity

  root '.entrybox'

  field :title,         :selector => '.caption a'
  field :body,          :selector => 'td[@colspan="2"]'
  field :comment_link,  :selector => '.caption a' do |elm|
    elm['href']
  end
  
  pager do |doc|
    doc.css('a').select{|a| a.text =~ /earlier/i }.first['href'] rescue nil
  end
  
  before_paginate do
    # logging for fun
    puts "opening page: #{self.source}"
    puts "collection size: #{self.collection.length}"
    puts "*"*100
  end

end

LiveJournalPost.source = 'http://zeroplate.livejournal.com/'
@posts  = LiveJournalPost.all(:max_pages => 3)

@posts.each do |post|
  puts "#{post.title}"
  puts "#{post.comment_link}"
  puts "#{post.body}"
  puts "*"*100
end

puts "total: #{@posts.length}"
