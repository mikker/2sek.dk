require "./lib/environment"
require 'json'

class Ordbook < Sinatra::Base

  get '/' do
    erb :index
  end

  get "/lookup.json" do
    @words = Word.where("word LIKE ?", "#{params[:q]}%").limit(20).order("word").all
    content_type 'application/json'
    { words: @words }.to_json
  end

end
