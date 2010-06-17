require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class MockScraper
  include Graboid::Scraper
  
  set :title
  set :body
  set :author
  set :date, :selector => '.author' do |elm| 
    elm.text.match(/\((.*)\)/)[1] 
  end
end

class WorkingScraper
  include Graboid::Scraper
  
  selector '.post'
  
  set :title
  set :body
  set :author
  set :date, :selector => '.author' do |elm| 
    elm.text.match(/\((.*)\)/)[1] 
  end
end

class ScraperWithPager
  include Graboid::Scraper

  selector '.post'
  
  set :title
  set :body
  set :author
  set :date, :selector => '.author' do |elm| 
    elm.text.match(/\((.*)\)/)[1] 
  end

  page_with do |doc|
    'http://localhost:9393'+doc.css('a.next').first['href'] rescue nil
  end

  before_paginate do
    puts "page: #{self.source}"
  end

end



describe Graboid::Scraper do
  describe "#root_selector" do
    it "should be set" do
      MockScraper.root_selector.should == '.mock_scraper'
    end
    
    describe "when inferred from class" do
    
      before(:each) do
        class Phony; include Graboid::Scraper; end
      end
      
      it "should infer .phony" do
        Phony.root_selector.should == '.phony'
      end
    end
  end
  
  describe "#set" do
    describe "simple syntax" do
      
      before(:each) do
        MockScraper.set :body
      end
      
      it "should be set in the attr map" do
        MockScraper.attribute_map[:body].should be_a Hash
      end
      
      it "should set the selector" do
        MockScraper.attribute_map[:body][:selector].should == '.body'
      end
    end
    
    describe "custom selector syntax" do
      before(:each) do
        MockScraper.set :body, :selector => '.custom'
      end
      
      it "should set the selector" do
        MockScraper.attribute_map[:body][:selector].should == '.custom'
      end
    end
    
    describe "custom selector syntax with a lambda" do
      
      before(:each) do
        MockScraper.set :body, :selector => '.custom' do |item|
          "from lambda"
        end
      end
      
      it "should set the selector" do
        MockScraper.attribute_map[:body][:selector].should == '.custom'
      end
      
      it "should set the processor" do
        MockScraper.attribute_map[:body][:processor].should be_a Proc
      end
      
    end
  end
  
  describe "#new" do
    describe "when supplied a source" do
      before(:each) do
        @scraper = WorkingScraper.new( :source => TEST_SERVER_URL )
      end
      
      it "should have the correct attribute_map" do
        @scraper.attribute_map[:body][:selector].should == '.body'
      end
      
      it "should set the instance source" do
        @scraper.source.should == TEST_SERVER_URL
      end
      
      it "should set the doc source" do
        @scraper.doc.should be_a Nokogiri::HTML::Document
      end
    end
    
    describe "#all_fragments" do
      before(:each) do
        @scraper = WorkingScraper.new( :source => POSTS_HTML_STR )
        @fragments  = @scraper.all_fragments
      end

      it "should return the NodeSet" do
        @fragments.should be_a Nokogiri::XML::NodeSet
      end

      it "should have 2 results" do
        @fragments.count.should == 2
      end
    end
    
    describe "#all" do
      before(:each) do
        @scraper = WorkingScraper.new( :source => POSTS_HTML_STR )
      end

      it "should return 2 WorkingPosts" do
        @scraper.all(:max_pages => 3).length.should == 2
      end
      
      [:current_page, :max_pages].each do |m|
        describe "##{m}" do
          it "should be 0 by default" do
            @scraper.send(m).should == 0
          end
          it "should be 3" do
            @scraper.send("#{m}=",3)
            @scraper.send(m).should == 3
          end
        end
      end

    end
    
    describe "#page_with" do
      describe "with a limit" do
        before(:each) do
          @scraper = ScraperWithPager.new( :source => 'http://localhost:9393/posts' )
          @posts = @scraper.all(:max_pages => 3)
        end
        it "should get 6 posts" do
          @posts.length.should == 6
        end
      end

      describe "without a limit" do
        before(:each) do
          @scraper = ScraperWithPager.new( :source => 'http://localhost:9393/posts' )
          @posts = @scraper.all
        end
        it "should get 16 posts" do
          @posts.length.should == 16
        end
      end

    end
    
  end
  
  
  
  
end