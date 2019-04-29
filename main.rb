require 'sinatra'
require 'toml-rb'
require 'rack/contrib'
require 'dotenv/load'

FEEDS_TOML_PATH = './feeds.toml'.freeze

use Rack::PostBodyContentTypeParser

un = ENV.fetch("USERNAME")
pw = ENV.fetch("PASSWORD")
use Rack::Auth::Basic do |username, password|
  username == un && password == pw
end

get '/' do
  File.read('./front/dist/index.html')
end

get '/feeds.json' do
  TomlRB.parse(File.read(FEEDS_TOML_PATH)).to_json
end

post '/update' do
  File.write(FEEDS_TOML_PATH, TomlRB.dump(params))
  TomlRB.parse(File.read(FEEDS_TOML_PATH)).to_json
end
