module Database
  class Schema
    attr_reader :database

    def initialize(database)
      @database = database
    end

    def execute
      database.create_table :banks do
        primary_key :id
        String :name, size: 100, null: false, unique: true
      end

      database.create_table :accounts do
        primary_key :id
        foreign_key :bank_id, :banks, null: false
        String :name, size: 100, null: false
        BigDecimal :balance_in_cents, default: 0, null: false
      end

      database.create_table :transactions do
        primary_key :id
        foreign_key :from_account_id, :accounts, null: false
        foreign_key :to_account_id, :accounts, null: false
        BigDecimal :amount_in_cents, null: false
        DateTime :created_at, null: false, default: Sequel.function(:datetime, 'now')
      end
    end
  end
end
