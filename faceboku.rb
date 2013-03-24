require 'sinatra'
require 'omniauth-facebook'

require './helpers/get_post'

enable :sessions

# This might come from DB
APP_ID = "153304591365687"
APP_SECRET = "7a7663099ccb62f180d985ba1252a3e2"

use OmniAuth::Builder do  
  provider :facebook, APP_ID, APP_SECRET, { :scope => 'email, status_update, publish_stream' }
end

get_post '/' do
  @articles = []
  @articles << {:title => 'Getting Started with Heroku', :url => 'https://devcenter.heroku.com/articles/quickstart'}
  @articles << {:title => 'Deploying Rack-based apps in Heroku', :url => 'http://docs.heroku.com/rack'}
  @articles << {:title => 'Learn Ruby in twenty minutes', :url => 'http://www.ruby-lang.org/en/documentation/quickstart/'}

  erb :index
end

get '/auth/facebook/callback' do
  session['fb_auth'] = request.env['omniauth.auth']
  session['fb_token'] = session['fb_auth']['credentials']['token']
  session['fb_error'] = nil
  redirect '/'
end

get '/auth/failure' do
  clear_session
  session['fb_error'] = 'In order to use this site you must allow us access to your Facebook data<br />'
  redirect '/'
end

get '/logout' do
  clear_session
  redirect '/'
end

def clear_session
  session['fb_auth'] = nil
  session['fb_token'] = nil
  session['fb_error'] = nil
end
