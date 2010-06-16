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

class PostWithPager
  include Graboid::Entity

  selector '.post'
  
  set :title
  set :body
  set :author
  set :date, :selector => '.author' do |elm| 
    elm.text.match(/\((.*)\)/)[1] 
  end

  pager do |doc|
    'http://localhost:9393'+doc.css('a.next').first['href'] rescue nil
  end

  before_paginate do
    puts "page: #{self.source}"
  end

end

TEST_SERVER_URL = 'http://localhost:9393/posts'
