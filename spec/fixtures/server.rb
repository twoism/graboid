%w{rubygems sinatra}.each {|f| require f }

get "/posts" do
  @total_pages  = 8
  @page         = params[:page].to_i || 1
  @limit        = 2 
  erb :posts
end