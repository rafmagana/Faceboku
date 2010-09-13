require 'sinatra'
require 'omniauth/oauth'

#use OmniAuth::Strategies::Facebook, 'ccfda574d92e83a704ac982b33617f01', '7a7663099ccb62f180d985ba1252a3e2'

#Here you have to put your own Application ID and Secret
APP_ID = '153304591365687'
APP_SECRET = '7a7663099ccb62f180d985ba1252a3e2'

get '/' do
    @articles = []
    @articles << {:title => 'Deploying Rack-based apps in Heroku', :link => 'http://docs.heroku.com/rack/'}
    @articles << {:title => 'Learn Ruby in twenty minutes', :link => 'http://www.ruby-lang.org/en/documentation/quickstart/'}
    erb :index
end

get '/auth/facebook/callback' do
  #request.cookies["fb_"]
  #params[:auth].inspect
end