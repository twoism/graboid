require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class Post
  include Graboid::Entity
  
  root '.post'
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
        class Phony
          include Graboid::Entity
        end
      end
      
      it "should infer .post" do
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
        puts Post.doc.class
      end
    end
  end
  
end