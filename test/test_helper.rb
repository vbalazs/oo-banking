require "minitest/autorun"
require "sequel"

require "schema"
DB = Sequel.connect('sqlite://')
Database::Schema.new(DB).execute

require "sequel_test_case"
require "eager_load"

