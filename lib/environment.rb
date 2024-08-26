# encoding: utf-8
ENVIRONMENT = (ENV["RACK_ENV"] || :development).to_sym

require "logger"

class ::Logger
  alias_method :write, :<<
end

LOG = Logger.new(STDOUT)

require "bundler/setup"

Bundler.require(:default, ENVIRONMENT)
Dotenv.load if defined?(Dotenv)

Database = Sequel.connect("sqlite://db/data.sqlite")

Database.run(
  <<-SQL
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA journal_size_limit = 67108864; -- 64 megabytes
PRAGMA mmap_size = 134217728; -- 128 megabytes
PRAGMA cache_size = 2000;
PRAGMA busy_timeout = 5000;
  SQL
    .strip
)

Database.create_table?(:words) do
  primary_key(:id)
  String(:word, index: true, null: false)
  Text(:definition, null: false)
  String(:lang, length: 2, null: false)
end

class Word < Sequel::Model
  def to_json(opts = {})
    to_hash.to_json
  end
end
