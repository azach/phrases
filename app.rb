require 'haml'
require 'sinatra'
require 'json'
require 'warden'
require 'yaml'
require_relative 'phrases'

class PhrasesApp < Sinatra::Base
  CONF = YAML.load(File.read(File.join(File.expand_path(File.dirname(__FILE__)), 'conf.yml')))

  enable :sessions

  Phrases.initialize_phrases(CONF['phrases_file_path'])

  get '/' do
    haml :home
  end

  get '/login' do
    session['logged_in'] = true
    redirect '/'
  end

  get '/logout' do
    session['logged_in'] = nil
    redirect '/'
  end

  post '/unauthenticated/?' do
    status 401
    request.env['warden'].custom_failure!
  end

  before '/api/*' do
    request.env['warden'].authenticate!
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
    config.scope_defaults :default, strategies: [:session, :access_token]
    config.failure_app = self
  end

  # Authentication strategy for non-session based clients (e.g. mobile app)
  Warden::Strategies.add(:access_token) do
    def valid?
      request.env['HTTP_ACCESS_TOKEN'].is_a?(String)
    end

    def authenticate!
      access_granted = (request.env['HTTP_ACCESS_TOKEN'] == CONF['access_token'])
      access_granted ? success!(true) : fail!
    end
  end

  Warden::Strategies.add(:session) do
    def valid?
      !!session['logged_in']
    end

    def authenticate!
      !!session['logged_in'] ? success!(true) : fail!
    end
  end
end
