$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'graboid'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
end

FIXTURE_PATH    = File.expand_path(File.dirname(__FILE__)+'/fixtures/posts.html')
POSTS_HTML_STR  = File.read(FIXTURE_PATH){|f| f.read }
POST_DOC        = Nokogiri::HTML(POSTS_HTML_STR)
POST_FRAGMENT   = Nokogiri::HTML::fragment(POST_DOC.css('.post').first.to_html)

class Post
  include Graboid::Entity
  
  selector '.post'
end

class WorkingPost
  include Graboid::Entity
  
  selector '.post'
  
  set :title
  set :body
  set :author
  set :date, :selector => '.author' do |elm| 
    elm.text.match(/\((.*)\)/)[1] 
  end
end

class RedditEntry
  include Graboid::Entity

  selector '.entry'

  set :title
  set :domain, :selector => '.domain a'
  set :link,   :selector => '.title' do |entry| 
    entry.css('a').first['href'] 
  end

  pager do |doc|
    doc.css('p.nextprev a').select{|a| a.text =~ /next/i  }.first['href']
  end

  before_paginate do
    puts "page: #{self.current_page}"
  end

end
