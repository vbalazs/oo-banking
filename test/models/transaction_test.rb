require "test_helper"

module Models
  class TestTransaction < Minitest::Test
    def test_initialization
      transaction = Transaction.new(from_account: 1)
      assert_equal 1, transaction.from_account
      assert_equal "queued", transaction.status
    end
  end
end
