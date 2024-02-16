# frozen_string_literal: true

require 'rom-sql'
require 'rom/sql/rake_task'
require 'pry'
require 'uri'

namespace :auction_fun_core do
  namespace :db do
    uri = URI.parse(ENV.fetch('DATABASE_URL'))
    @database_name = (uri.path || '').split('/').last
    @database_host = uri.host

    desc 'Perform migration reset (full erase and migration up)'
    task :rom_configuration do
      Rake::Task['auction_fun_core:db:setup'].invoke
    end

    desc 'Prepare database for running migrations'
    task :setup do
      AuctionFunCore::Application.start(:db)
      ROM::SQL::RakeSupport.env = ROM.container(AuctionFunCore::Application[:db_config])
    end

    desc 'Perform migration reset (full erase and migration up)'
    task reset: :rom_configuration do
      ROM::SQL::RakeSupport.run_migrations(target: 0)
      ROM::SQL::RakeSupport.run_migrations
      puts '<= db:reset executed'
    end

    desc 'Create a postgres database'
    task :create_database, [:userdb] do |_t, args|
      command = "CREATE DATABASE #{@database_name} LOCALE 'en_US.utf8' ENCODING UTF8 TEMPLATE template0;"

      sh %(psql -h #{@database_host} -U #{args[:userdb]} -c "#{command}")
    end

    desc 'Drop a postgres database'
    task :drop_database, [:userdb] do |_t, args|
      sh %(psql -h #{@database_host} -U #{args[:userdb]} -c "DROP DATABASE #{@database_name};")
    end

    desc 'Migrate the database (options [version_number])]'
    task :migrate, [:version] => :rom_configuration do |_, args|
      version = args[:version]

      if version.nil?
        ROM::SQL::RakeSupport.run_migrations
        puts '<= db:migrate executed'
      else
        ROM::SQL::RakeSupport.run_migrations(target: version.to_i)
        puts "<= db:migrate version=[#{version}] executed"
      end
    end

    desc 'Perform migration down (removes all tables)'
    task clean: :rom_configuration do
      ROM::SQL::RakeSupport.run_migrations(target: 0)
      puts '<= db:clean executed'
    end

    desc 'Seed data'
    task :seed_database do
      Rake::Task['auction_fun_core:db:setup'].invoke
      seed_file = AuctionFunCore::Application.root.join('db', 'seeds.rb')
      raise 'You tried to load seed data, but no seed loader is specified' unless seed_file

      load(seed_file)
    end
  end
end
