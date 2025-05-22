require 'sequel'
require 'dotenv'

Dotenv.load

namespace :db do
  desc 'Create the database'
  task :create do
    db_url = ENV['DATABASE_URL'] || 'postgres://tvshows:tvshows@localhost:5432/tvshows'
    db_name = db_url.split('/').last
    system "createdb #{db_name}"
  end

  desc 'Run database migrations'
  task :migrate do
    db_url = ENV['DATABASE_URL'] || 'postgres://tvshows:tvshows@localhost:5432/tvshows'
    Sequel.extension :migration
    DB = Sequel.connect(db_url)
    Sequel::Migrator.run(DB, 'db/migrate')
  end

  desc 'Rollback database migrations'
  task :rollback do
    db_url = ENV['DATABASE_URL'] || 'postgres://tvshows:tvshows@localhost:5432/tvshows'
    Sequel.extension :migration
    DB = Sequel.connect(db_url)
    Sequel::Migrator.run(DB, 'db/migrate', target: 0)
  end
end
