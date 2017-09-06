require './lib/environment'
require 'json'
require 'tilt/erb'

class Ordbook < Sinatra::Base
  set :environment, ENVIRONMENT

  configure do
    enable :logging
    use Rack::CommonLogger, LOG
  end

  before do
    Database.logger = request.logger
    expires 500, :public, :must_revalidate
  end

  get '/' do
    erb :index
  end

  get '/lookup.json' do
    @words = Word.where(
      Sequel.like(:word, "#{params[:q].downcase}%")
    ).limit(20).order(:word).all

    content_type 'application/json'
    { words: @words }.to_json
  end
end
