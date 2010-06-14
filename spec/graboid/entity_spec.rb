require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class Post
  include Graboid::Entity
  
  selector '.post'
end

describe Graboid::Entity do
  describe "#source" do
    describe "when url" do
      before(:each) do
        Post.source = 'http://foo.com/'
      end
  
      it "should set the source" do
        Post.source.should == 'http://foo.com/'
      end
    end
  end
  
  describe "#root_selector" do
    
    it "should be set" do
      Post.root_selector.should == '.post'
    end
    
    describe "when inferred from class" do
    
      before(:each) do
        class Phony; include Graboid::Entity; end
      end
      
      it "should infer .phony" do
        Phony.root_selector.should == '.phony'
      end
    end
  end
  
  describe "#doc" do
    
    describe "when supplied a url" do
      
      before(:each) do
        Post.source = 'http://google.com'
      end
      
      it "should set the doc source" do
        Post.doc.should be_a Nokogiri::HTML::Document
      end
      
    end
    
    describe "when supplied html" do
      
      before(:each) do
        Post.source = POSTS_HTML_STR
      end
      
      it "should set the doc source" do
        Post.doc.should be_a Nokogiri::HTML::Document
      end
      
    end
  
  end
  
  describe "#set" do
    describe "simple syntax" do
      
      before(:each) do
        Post.set :body
      end
      
      it "should be set in the attr map" do
        Post.attribute_map[:body].should be_a Hash
      end
      
      it "should set the selector" do
        Post.attribute_map[:body][:selector].should == '.body'
      end
    end
    
    describe "custom selector syntax" do
      before(:each) do
        Post.set :body, :selector => '.custom'
      end
      
      it "should set the selector" do
        Post.attribute_map[:body][:selector].should == '.custom'
      end
    end
    
    describe "custom selector syntax with a lambda" do
      
      before(:each) do
        Post.set :body, :selector => '.custom' do |item|
          "from lambda"
        end
      end
      
      it "should set the selector" do
        Post.attribute_map[:body][:selector].should == '.custom'
      end
      
      it "should set the processor" do
        Post.attribute_map[:body][:processor].should be_a Proc
      end
      
    end
  end
  
  describe "#all_fragments" do
    before(:each) do
      
      class WorkingPost
        include Graboid::Entity
        selector '.post'
        set :body
      end
  
      WorkingPost.source = POSTS_HTML_STR
      @fragments  = WorkingPost.all_fragments
    end
    
    it "should return the NodeSet" do
      @fragments.should be_a Nokogiri::XML::NodeSet
    end
    
    it "should have 2 results" do
      @fragments.count.should == 2
    end
    
  end
  
  describe "#extract_instance" do
    
    before(:each) do
      class WorkingPost
        include Graboid::Entity
        selector '.post'
        set :title
        set :body
        set :author
        set :date, :selector => '.author', :processor => lambda {|frag| frag.text.match(/\((.*)\)/)[1] }
      end
      
      @instance = WorkingPost.extract_instance(POST_FRAGMENT)
      
    end
    
    it "should return a WorkingPost instance" do
      @instance.should be_a WorkingPost
    end
    
    it "should respond to attrs defined in the map" do
      WorkingPost.attribute_map.each { |k,v| @instance.should respond_to(k)  }
    end
    
    it "should extract the date" do
      @instance.date.should == '06/11/2010'
    end
    
  end
  
  describe "#all" do
    before(:each) do
      class WorkingPost
        include Graboid::Entity
        selector '.post'
        set :title
        set :body
        set :author
        set :date, :selector => '.author', :processor => lambda {|frag| frag.text.match(/\((.*)\)/)[1] }
      end
      
      WorkingPost.source = POSTS_HTML_STR
      
    end
    
    it "should return 2 WorkingPosts" do
      WorkingPost.all.length.should == 2
    end
    
  end
  
  # describe "#pager" do
  #     before(:each) do
  # 
  #       class DiggPost
  #         include Graboid::Entity
  #         selector '.news-summary'
  #         set :title, :selector => '.news-body h3'
  #         
  #         pager do |doc|
  #           url = doc.css('a.nextprev').select{|e| e.text == 'Next'  }.first['href'] rescue nil
  #           url = "http://digg.com#{url}" if url
  #           url
  #         end
  #       end
  # 
  #       DiggPost.source = 'http://digg.com/'
  #       @posts = DiggPost.all(10)
  #     end
  #     it "should" do
  #       @posts.each do |p|
  #         puts p.title
  #       end
  #       puts @posts.length
  #     end
  #   end
  
  
end