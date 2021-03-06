require "test_helper"

module Repositories
  class TransactionsTest < SequelTestCase
    def setup
      @accounts_repo = Accounts.new
      @repo = Transactions.new(accounts_repository: @accounts_repo)
      @bank = Models::Bank.create(name: "Bank 1")
    end

    def test_add
      account1 = @accounts_repo.create(name: "Account 1", bank: @bank)
      account2 = @accounts_repo.create(name: "Account 2", bank: @bank)
      transaction = Models::Transaction.new(from_account: account1,
        to_account: account2, amount_in_cents: 50)

      result = @repo.add(transaction)

      assert_equal account1, result.from_account
      assert_equal account2, result.to_account
      assert_equal 50, result[:amount_in_cents]
    end

    def test_add_fails_with_negative_amount
      account1 = @accounts_repo.create(name: "Account 1", bank: @bank)
      account2 = @accounts_repo.create(name: "Account 2", bank: @bank)
      transaction = Models::Transaction.new(from_account: account1,
        to_account: account2, amount_in_cents: -10)

      assert_raises(NegativeTransferAmount) { @repo.add(transaction) }
    end

    def test_transfer_ignores_zero_amount
      account1 = @accounts_repo.create(name: "Account 1",
        bank: @bank, balance_in_cents: 45)
      transaction = Models::Transaction.new(from_account: account1,
        to_account: nil, amount_in_cents: 0)

      assert_nil @repo.transfer(transaction: transaction)
      assert_equal 0, Models::Transaction.count
    end

    def test_transfer_fails_if_balance_is_not_enough
      account1 = @accounts_repo.create(name: "Account 1",
        bank: @bank, balance_in_cents: 45)
      transaction = Models::Transaction.new(from_account: account1,
        to_account: nil, amount_in_cents: 50)

      assert_raises(InsufficientAccountBalance) { @repo.transfer(transaction: transaction) }
    end

    def test_transfer_fails_if_balance_is_not_enough_with_commission
      account1 = @accounts_repo.create(name: "Account 1",
        bank: @bank, balance_in_cents: 50)
      transaction = Models::Transaction.new(from_account: account1,
        to_account: nil, amount_in_cents: 50)

      assert_raises(InsufficientAccountBalance) do
        @repo.transfer(transaction: transaction, commission: 1)
      end
    end

    def test_transfer_subtracts_from_source_account
      account1 = @accounts_repo.create(name: "Account 1",
        bank: @bank, balance_in_cents: 50)
      account2 = @accounts_repo.create(name: "Account 2", bank: @bank)
      transaction = Models::Transaction.new(from_account: account1,
        to_account: account2, amount_in_cents: 30)

      @repo.transfer(transaction: transaction, commission: 2)

      assert_equal 18, account1.refresh.balance_in_cents
    end

    def test_transfer_adds_record
      account1 = @accounts_repo.create(name: "Account 1",
        bank: @bank, balance_in_cents: 50)
      account2 = @accounts_repo.create(name: "Account 2", bank: @bank)
      transaction = Models::Transaction.new(from_account: account1,
        to_account: account2, amount_in_cents: 30)

      @repo.transfer(transaction: transaction)

      assert_equal 1, Models::Transaction.count
    end

    def test_by_bank
      bank2 = Models::Bank.create(name: "2nd bank")
      bank3 = Models::Bank.create(name: "3rd bank")
      account1 = @accounts_repo.create(name: "Account 1", bank: @bank)
      account2 = @accounts_repo.create(name: "Account 2", bank: bank2)
      account3 = @accounts_repo.create(name: "Account 3", bank: bank3)
      t1 = Models::Transaction.create(from_account: account1, to_account: account2,
        amount_in_cents: 1)
      t2 = Models::Transaction.create(from_account: account1, to_account: account3,
        amount_in_cents: 2)
      t3 = Models::Transaction.create(from_account: account2, to_account: account3,
        amount_in_cents: 3)

      assert_equal [t1.id, t2.id], @repo.by_bank(@bank).select_map(Sequel[:transactions][:id])
      assert_equal [t1.id, t3.id], @repo.by_bank(bank2).select_map(Sequel[:transactions][:id])
    end
  end
end
