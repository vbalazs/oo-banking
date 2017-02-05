module Repositories
  class Transactions
    def initialize(accounts_repository: Accounts.new)
      @accounts_repository = accounts_repository
    end

    def by_bank(bank, limit = 10, offset = 0)
      Models::Transaction.association_join(:from_account)
                         .association_join(:to_account)
                         .where(Sequel.or(
                            Sequel[:from_account][:bank_id] => bank.id,
                            Sequel[:to_account][:bank_id] => bank.id))
                         .order(:created_at)
                         .limit(limit, offset)
    end

    def transfer(transaction:, commission: 0)
      return unless transaction.amount_in_cents.positive?

      total_cost = transaction.amount_in_cents + commission
      check_for_balance!(transaction.from_account, total_cost)

      Models::Transaction.db.transaction do
        accounts_repository.subtract_from(transaction.from_account, total_cost)
        accounts_repository.add_to(transaction.to_account, transaction.amount_in_cents)
        add(transaction)
      end
    end

    def add(transaction)
      raise NegativeTransferAmount unless transaction.amount_in_cents.positive?

      Models::Transaction.create(
        from_account: transaction.from_account,
        to_account: transaction.to_account,
        amount_in_cents: transaction.amount_in_cents
      )
    end

    private

    attr_reader :accounts_repository

    # rubocop:disable Style/GuardClause
    def check_for_balance!(account, subtraction)
      if account.balance_in_cents < subtraction
        raise InsufficientAccountBalance,
          "Balance #{account.balance_in_cents} is not enough for #{subtraction}"
      end
    end
    # rubocop:enable Style/GuardClause
  end

  class InsufficientAccountBalance < StandardError; end
  class NegativeTransferAmount < StandardError; end
end
