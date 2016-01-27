require "./lib/environment"
require 'json'
require 'tilt/erb'

Opbeat.start!(Opbeat::Configuration.new do |c|
  c.organization_id = ENV.fetch('OPBEAT_ORGANIZATION_ID')
  c.app_id = ENV.fetch('OPBEAT_APP_ID')
  c.secret_token = ENV.fetch('OPBEAT_SECRET_TOKEN')

  c.debug_traces = ENVIRONMENT == :development
  c.transaction_post_interval = 10
  c.logger = LOG
end)

class Ordbook < Sinatra::Base
  use Opbeat::Middleware

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

  get "/lookup.json" do
    @words = Word.where("word LIKE ?", "#{params[:q].downcase}%").limit(20).order(:word).all
    content_type 'application/json'
    { words: @words }.to_json
  end

end
