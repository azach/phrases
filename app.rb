require 'erb'
require 'sinatra'
require 'json'
require 'warden'
require 'yaml'
require_relative 'phrases'

class PhrasesApp < Sinatra::Base
  CONF = YAML.load(File.read(File.join(File.expand_path(File.dirname(__FILE__)), 'conf.yml')))

  Phrases.initialize_phrases(CONF['phrases_file_path'])

  get '/' do
    'Welcome to Phrases!'
  end

  post '/unauthenticated/?' do
    status 401
    request.env['warden'].custom_failure!
  end

  before '/api/*' do
    request.env['warden'].authenticate!(:access_token)
  end

  get '/api/phrase.json' do
    content_type :json
    {phrase: Phrases.get(params[:search])}.to_json
  end

  post '/api/phrase.json' do
    error 400 unless params[:phrase] && !params[:phrase].empty?
    Phrases.add(params[:phrase])
    {phrase: params[:phrase]}.to_json
  end

  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = "POST"
  end

  use Warden::Manager do |config|
    config.scope_defaults :default, strategies: [:access_token]
    config.failure_app = self
  end

  Warden::Strategies.add(:access_token) do
    def valid?
      request.env['HTTP_ACCESS_TOKEN'].is_a?(String)
    end

    def authenticate!
      access_granted = (request.env['HTTP_ACCESS_TOKEN'] == CONF['access_token'])
      !access_granted ? fail! : success!(access_granted)
    end
  end
end
