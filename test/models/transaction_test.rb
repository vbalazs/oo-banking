require "test_helper"

module Models
  class TransactionTest < SequelTestCase
    def setup
      @accounts_repo = Repositories::Accounts.new
      @bank = Bank.create(name: "test")
    end

    def test_initialization
      account_1 = @accounts_repo.create(name: "A", bank: @bank)
      account_2 = @accounts_repo.create(name: "B", bank: @bank)
      transaction = Transaction.create(from_account: account_1, to_account: account_2,
        amount_in_cents: 1)

      assert_equal account_1, transaction.from_account
      assert_equal account_2, transaction.to_account
      assert_equal 1, transaction.amount_in_cents
    end
  end
end
