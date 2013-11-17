require "./lib/environment"
require 'json'

class Ordbook < Sinatra::Base

  set :environment, ENVIRONMENT

  configure :production, :development do
    enable :logging
    file = File.new("./log/#{settings.environment}.log", 'a+')
    file.sync = true
    use Rack::CommonLogger, file
  end

  get '/' do
    erb :index
  end

  get "/lookup.json" do
    @words = Word.where("word LIKE ?", "#{params[:q].downcase}%").limit(20).order("word").all
    content_type 'application/json'
    { words: @words }.to_json
  end

end
