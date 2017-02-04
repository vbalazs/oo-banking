require "sequel"

# connect to an in-memory database
DB = Sequel.sqlite

require_relative "schema"
Database::Schema.new(DB).execute

require_relative "seed"
Database::SeedData.new(DB).execute
