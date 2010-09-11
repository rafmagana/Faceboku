require 'sinatra'
require 'omniauth/oauth'

#use OmniAuth::Strategies::Facebook, 'ccfda574d92e83a704ac982b33617f01', '7a7663099ccb62f180d985ba1252a3e2'

get '/' do
  erb :index
end

get '/auth/facebook/callback' do
  #request.cookies["fb_"]
  #params[:auth].inspect
end