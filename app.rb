require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader' if development?
require 'sequel'
require 'httparty'
require 'dotenv'
require 'rack/cors'
require 'kaminari'
require 'json'

# Load environment variables
Dotenv.load

# Configure CORS
configure do
  enable :logging
  set :bind, '0.0.0.0'
  set :port, 4567
end

# Database configuration
DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://tvshows:tvshows@localhost:5432/tvshows')

# Load models
require_relative 'models/tv_show'
require_relative 'models/distributor'
require_relative 'models/release_date'

# Load services
require_relative 'services/tvmaze_service'
require_relative 'services/ingestion_service'

# Load API routes
require_relative 'routes/tv_shows'

# Mount the TVShowsAPI
class App < Sinatra::Base
  # Mount the TVShowsAPI under /v1
  use TVShowsAPI, base_path: '/v1'

  # Health check endpoint
  get '/health' do
    json status: 'ok'
  end
end
