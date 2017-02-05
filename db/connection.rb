require "sequel"

require "schema"
require "seed"

# connect to an in-memory database
DB = Sequel.connect("sqlite://")
Database::Schema.new(DB).execute
Database::SeedData.new(DB).execute
