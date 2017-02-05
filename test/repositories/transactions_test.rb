require "test_helper"

module Repositories
  class TransactionsTest < SequelTestCase
    def setup
      @accounts_repo = Accounts.new
      @repo = Transactions.new(accounts_repository: @accounts_repo)
      @bank = Models::Bank.create(name: "Bank 1")
    end

    def test_add
      account_1 = @accounts_repo.create(name: "Account 1", bank: @bank)
      account_2 = @accounts_repo.create(name: "Account 2", bank: @bank)
      transaction = Models::Transaction.new(from_account: account_1,
        to_account: account_2, amount_in_cents: 50)

      result = @repo.add(transaction)

      assert_equal account_1, result.from_account
      assert_equal account_2, result.to_account
      assert_equal 50, result[:amount_in_cents]
    end

    def test_add_fails_with_negative_amount
      account_1 = @accounts_repo.create(name: "Account 1", bank: @bank)
      account_2 = @accounts_repo.create(name: "Account 2", bank: @bank)
      transaction = Models::Transaction.new(from_account: account_1,
        to_account: account_2, amount_in_cents: -10)

      assert_raises(NegativeTransferAmount) { @repo.add(transaction) }
    end

    def test_transfer_ignores_zero_amount
      account_1 = @accounts_repo.create(name: "Account 1",
        bank: @bank, balance_in_cents: 45)
      transaction = Models::Transaction.new(from_account: account_1,
        to_account: nil, amount_in_cents: 0)

      assert_nil @repo.transfer(transaction: transaction)
      assert_equal 0, Models::Transaction.count
    end

    def test_transfer_fails_if_balance_is_not_enough
      account_1 = @accounts_repo.create(name: "Account 1",
        bank: @bank, balance_in_cents: 45)
      transaction = Models::Transaction.new(from_account: account_1,
        to_account: nil, amount_in_cents: 50)

      assert_raises(InsufficientAccountBalance) { @repo.transfer(transaction: transaction) }
    end

    def test_transfer_fails_if_balance_is_not_enough_with_commission
      account_1 = @accounts_repo.create(name: "Account 1",
        bank: @bank, balance_in_cents: 50)
      transaction = Models::Transaction.new(from_account: account_1,
        to_account: nil, amount_in_cents: 50)

      assert_raises(InsufficientAccountBalance) { @repo.transfer(transaction: transaction, commission: 1) }
    end

    def test_transfer_subtracts_from_source_account
      account_1 = @accounts_repo.create(name: "Account 1",
        bank: @bank, balance_in_cents: 50)
      account_2 = @accounts_repo.create(name: "Account 2", bank: @bank)
      transaction = Models::Transaction.new(from_account: account_1,
        to_account: account_2, amount_in_cents: 30)

      @repo.transfer(transaction: transaction, commission: 2)

      assert_equal 18, account_1.refresh.balance_in_cents
    end

    def test_transfer_adds_record
      account_1 = @accounts_repo.create(name: "Account 1",
        bank: @bank, balance_in_cents: 50)
      account_2 = @accounts_repo.create(name: "Account 2", bank: @bank)
      transaction = Models::Transaction.new(from_account: account_1,
        to_account: account_2, amount_in_cents: 30)

      @repo.transfer(transaction: transaction)

      assert_equal 1, Models::Transaction.count
    end
  end
end
