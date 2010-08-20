require 'rubygems'
require 'sinatra'
require 'net/http'

APP_URL = 'http://color-theme-select.heroku.com'
GIST_URL   = 'http://gist.github.com/%s.txt'
GIST_CREATE_URL = 'http://gist.github.com/gists'

set :haml, {:format => :html5}

get '/' do
  haml :index
end

get '/download/http:/*' do
  uri = 'http://'+params[:splat].first
  if request.query_string != ""
    uri += "?" + request.query_string
  end
  puts "DOWNLOADING #{uri}"
  response = Net::HTTP.get_response(URI.parse(uri))
  response.body    
end

get '/download/*' do 
  file = File.expand_path('public/'+params[:splat].first,
                          File.dirname(__FILE__))
  if File.exist?(file)
    return send_file(file)
  end

  uri = 'http://'+params[:splat].first
  if request.query_string != ""
    uri += "?" + request.query_string
  end                                                               
  response = Net::HTTP.get_response(URI.parse(uri))
  response.body    
end

get %r[/gist/(\d+)/(elisp|json)(/(.*))?] do
  number = params[:captures][0]
  type = params[:captures][1]
  filename = params[:captures][3]
  uri = "http://gist.github.com/raw/#{number}/#{type}"
  res = Net::HTTP.get_response(URI.parse(uri))
  attachment filename if filename
  content_type :json
  res.body
end

post '/gist' do
  data = Hash.new
  data['file_name[gistfile1]'] = 'README'
  data['file_ext[gistfile1]'] = '.txt'
  data['file_contents[gistfile1]'] = <<-README
Emacs color-theme #{params[:name]}
Generated at #{Date.new} using #{APP_URL}

#{params[:docs]}
README

  data['file_name[gistfile2]'] = 'elisp'
  data['file_ext[gistfile2]'] = '.el'
  data['file_contents[gistfile2]'] = params[:lisp]

  data['file_name[gistfile3]'] = 'json'
  data['file_ext[gistfile3]'] = '.json'
  data['file_contents[gistfile3]'] = params[:json]

  data['file_name[gistfile4]'] = 'less'
  data['file_ext[gistfile4]'] = '.less'
  data['file_contents[gistfile4]'] = params[:less]
    
  res = Net::HTTP.post_form(URI.parse(GIST_CREATE_URL),
                            data)
  res['location'][/\d+/]
end
