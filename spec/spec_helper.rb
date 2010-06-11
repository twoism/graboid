$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'graboid'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
end

file_path       = File.expand_path(File.dirname(__FILE__)+'/fixtures/posts.html')
POSTS_HTML_STR  = File.read(file_path){|f| f.read }
