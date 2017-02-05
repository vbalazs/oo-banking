module Database
  class SeedData
    attr_reader :database

    def initialize(database)
      @database = database
    end

    def execute
      banks = database.from(:banks)
      alpha_id = banks.insert(name: "Alpha")
      beta_id = banks.insert(name: "Beta")

      accounts = database.from(:accounts)
      accounts.insert(name: "Jim's account", bank_id: alpha_id, balance_in_cents: 3000_000)
      accounts.insert(name: "Other alpha account", bank_id: alpha_id, balance_in_cents: 1_000)

      accounts.insert(name: "Emma's account", bank_id: beta_id, balance_in_cents: 25_000)
      accounts.insert(name: "Other beta account", bank_id: beta_id, balance_in_cents: 500)
    end
  end
end
