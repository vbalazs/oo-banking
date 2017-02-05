module Repositories
  class Accounts

    def create(args)
      Models::Account.create(args)
    end

    def subtract_from(account, amount)
      Models::Account[account.id].update(balance_in_cents: Sequel[:balance_in_cents] - amount)
    end

    def add_to(account, amount)
      Models::Account[account.id].update(balance_in_cents: Sequel[:balance_in_cents] + amount)
    end
  end
end
