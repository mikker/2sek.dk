# encoding: utf-8
ENVIRONMENT = ENV['RACK_ENV'] || :development

require 'logger'
class ::Logger; alias_method :write, :<<; end
LOG = Logger.new("log/#{ENVIRONMENT}.log")

require 'bundler/setup'
Bundler.require(:default, ENVIRONMENT)

Database = Sequel.connect ENV['DATABASE_URL'] || "sqlite://db/#{ENVIRONMENT}.sqlite"

Database.create_table? :words do
  primary_key :id
  String :word, index: true, null: false
  Text :definition, null: false
  String :lang, length: 2, null: false
end

class Word < Sequel::Model
  def to_json(opts = {})
    to_hash.to_json
  end
end

