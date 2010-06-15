require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
      WorkingPost.source = POSTS_HTML_STR
    end
    
    it "should return 2 WorkingPosts" do
      WorkingPost.all.length.should == 2
    end
    
  end
  
  [:current_page, :max_pages].each do |m|
    describe "##{m}" do
      it "should be 0 by default" do
        Post.send(m).should == 0
      end
      it "should be 3" do
        Post.send("#{m}=",3)
        Post.send(m).should == 3
      end
    end
  end
  
  describe "#mode" do
    it "should be html by default" do
      WorkingPost.mode.should == :html
    end
    it "should throw an error for invalid values" do
      lambda {
        WorkingPost.mode = :derp
      }.should raise_error ArgumentError
    end
    it "should change to :xml" do
      WorkingPost.mode = :xml
      WorkingPost.mode.should == :xml
    end
  end  
  
  describe "#pager" do
    describe "with a limit" do
      before(:each) do
        PostWithPager.source = 'http://localhost:9393/posts'
        @posts = PostWithPager.all(:max_pages => 3)
      end
      it "should get 2 posts" do
        @posts.length.should == 6
      end
    end
    
    describe "without a limit" do
      before(:each) do
        PostWithPager.source = 'http://localhost:9393/posts'
        @posts = PostWithPager.all
      end
      it "should get 2 posts" do
        @posts.length.should == 16
      end
    end
    
  end
    
end