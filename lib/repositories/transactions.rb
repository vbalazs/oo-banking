module Repositories
  class Transactions
    def initialize(accounts_repository: Accounts.new)
      @accounts_repository = accounts_repository
    end

    def transfer(transaction:, commission: 0)
      total_cost = transaction.amount_in_cents + commission
      check_for_balance!(transaction.from_account, total_cost)

      Models::Transaction.db.transaction do
        accounts_repository.subtract_from(transaction.from_account, total_cost)
        accounts_repository.add_to(transaction.to_account, transaction.amount_in_cents)
        add(transaction)
      end
    end

    def add(transaction)
      raise NegativeTransferAmount if transaction.amount_in_cents < 0

      Models::Transaction.create(
        from_account: transaction.from_account,
        to_account: transaction.to_account,
        amount_in_cents: transaction.amount_in_cents
      )
    end

    private

    attr_reader :accounts_repository

    def check_for_balance!(account, subtraction)
      if account.balance_in_cents < subtraction
        raise InsufficientAccountBalance,
          "Balance #{account.balance_in_cents} is not enough for #{subtraction}"
      end
    end
  end

  class InsufficientAccountBalance < StandardError; end
  class NegativeTransferAmount < StandardError; end
end
