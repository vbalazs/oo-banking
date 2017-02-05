require "test_helper"

module Repositories
  class AccountsTest < SequelTestCase
    def setup
      @repo = Accounts.new
      @bank = Models::Bank.create(name: "Bank 1")
    end

    def test_create
      result = @repo.create(name: "Test Account", bank: @bank)

      assert_equal 1, Models::Account.count
      assert_equal "Test Account", result.name
      assert_equal @bank, result.bank
      assert_equal 0, result.balance_in_cents
    end

    def test_subtract_from
      account = Models::Account.create(name: "other", bank: @bank, balance_in_cents: 20)

      @repo.subtract_from(account, 3)

      assert_equal 17, account.refresh.balance_in_cents
    end

    def test_add_to
      account = Models::Account.create(name: "other", bank: @bank, balance_in_cents: 20)

      @repo.add_to(account, 3)

      assert_equal 23, account.refresh.balance_in_cents
    end
  end
end
