require "sequel"

# connect to an in-memory database
DB = Sequel.sqlite

DB.create_table :banks do
  primary_key :id
  String :name, size: 100, null: false, unique: true
end

DB.create_table :accounts do
  primary_key :id
  foreign_key :bank_id, :banks, null: false
  String :name, size: 100, null: false
  BigDecimal :balance_in_cents, default: 0, null: false
end

DB.create_table :transactions do
  primary_key :id
  foreign_key :from_account_id, :accounts, null: false
  foreign_key :to_account_id, :accounts, null: false
  BigDecimal :amount_in_cents, null: false
end

require_relative "seed"
SeedData.new(DB).execute
