require 'sinatra'
require 'json'
require_relative 'phrases'

PHRASES_FILE_PATH = '/tmp/test'

Phrases.initialize_phrases(PHRASES_FILE_PATH)

get '/api/phrase.json' do
  content_type :json
  {phrase: Phrases.get(params[:search])}.to_json
end

post '/api/phrase.json' do
  return 400 unless params[:phrase] && !params[:phrase].empty?
  Phrases.add(params[:phrase])
  {phrase: params[:phrase]}.to_json
end
