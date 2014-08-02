require 'sinatra'
require 'json'
require_relative 'phrases'

PHRASES_FILE_PATH = '/tmp/test'

Phrases.initialize_phrases(PHRASES_FILE_PATH)

get '/api/phrase.json' do
  content_type :json
  {phrase: Phrases.get(params[:search])}.to_json
end
