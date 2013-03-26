require 'sinatra'
require "sinatra/cookies"
require 'omniauth-facebook'
require 'fb_graph'
require './helpers/get_post'

enable :sessions

set :protection, :except => :frame_options

configure do
  set :redirect_uri, nil
end

# Used when app is browsed outside FB's iframe
# When auth fails in FB, POST /canvas/ redirects to /auth/failure
OmniAuth.config.on_failure = lambda do |env|
  [302, {'Location' => '/auth/failure', 'Content-Type' => 'text/html'}, []]
end

# This might come from DB
APP_ID = "153304591365687"
APP_SECRET = "7a7663099ccb62f180d985ba1252a3e2"

use OmniAuth::Builder do
  provider :facebook, APP_ID, APP_SECRET, { :scope => 'email, status_update, publish_stream' }
end

# This content is accessible for everyone
# but only people logged in with FB credentials
#   would be able to Like links and the page
get_post '/' do
  @articles = []
  @articles << {:title => 'Getting Started with Heroku', :url => 'https://devcenter.heroku.com/articles/quickstart'}
  @articles << {:title => 'Deploying Rack-based apps in Heroku', :url => 'http://docs.heroku.com/rack'}
  @articles << {:title => 'Learn Ruby in twenty minutes', :url => 'http://www.ruby-lang.org/en/documentation/quickstart/'}

  erb :index
end

# This is called after successful authentication via /auth/facebook/
get '/auth/facebook/callback' do
  fb_auth = request.env['omniauth.auth']
  session['fb_auth'] = fb_auth
  session['fb_token'] = cookies[:fb_token] = fb_auth['credentials']['token']
  session['fb_error'] = nil
  redirect '/'
end

# If user doesn't grant us access or 
#   there's some failure regarding auth, 
#   this handles it
get '/auth/failure' do
  clear_session
  session['fb_error'] = 'In order to use all the Facebook features in this site you must allow us access to your Facebook data...<br />'
  redirect '/'
end

get '/login' do
  if settings.redirect_uri
    # we're in FB
    erb :dialog_oauth
  else
    # we aren't in FB (standalone app)
    redirect '/auth/facebook'
  end
end

get '/logout' do
  clear_session
  redirect '/'
end

# access point from FB, Canvas URL and Secure Canvas URL must be point to this route
# Canvas URL: http://your_app/canvas/
# Secure Canvas URL: https://your_app:443/canvas/
post '/canvas/' do

  # User didn't grant us permission in the oauth dialog
  redirect '/auth/failure' if request.params['error'] == 'access_denied'

  # see /login
  settings.redirect_uri = 'https://apps.facebook.com/faceboku/'

  # Canvas apps send the 'code' parameter
  # We use it to know if we're accessing the app from FB's iFrame
  # If so, we try to autologin
  url = request.params['code'] ? "/auth/facebook?signed_request=#{request.params['signed_request']}&state=canvas" : '/login'
  redirect url
end

def clear_session
  session['fb_auth'] = nil
  session['fb_token'] = nil
  session['fb_error'] = nil
  cookies[:fb_token] = nil
end

__END__

@@ dialog_oauth
<script>
  var oauth_url = 'https://www.facebook.com/dialog/oauth/';
  oauth_url += '?client_id=153304591365687';
  oauth_url += '&redirect_uri=' + encodeURIComponent('<%=settings.redirect_uri%>');
  oauth_url += '&scope=email, status_update, publish_stream'

  window.top.location = oauth_url;
</script>
