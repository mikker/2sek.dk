ENVIRONMENT = ENV['RACK_ENV'] || :development
require 'bundler/setup'
Bundler.require(:default, ENVIRONMENT)

`rm db/development.sqlite`
Database = Sequel.connect("sqlite://db/#{ENVIRONMENT}.sqlite")

Database.create_table :words do
  primary_key :id
  String :word, index: true, null: false
  Text :definition, null: false
  String :lang, length: 2, null: false
end

class Word < Sequel::Model
end

