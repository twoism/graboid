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
      
      it "should set the instance source" do
        @scraper.source.should == TEST_SERVER_URL
      end
      
      it "should set the doc source" do
        @scraper.doc.should be_a Nokogiri::HTML::Document
      end
    end
  end
  
  
end