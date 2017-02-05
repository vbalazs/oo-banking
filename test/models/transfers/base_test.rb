require "test_helper"

module Models
  module Transfers
    class DummyTransfer < Base
      def commission; 5; end
      def limit; 1000; end
      def external_failure?; false; end
    end

    class BaseTest < Minitest::Test
      def test_transfer_checks_for_limit
        transaction = Transaction.new(amount_in_cents: 101)
        obj = DummyTransfer.new(transaction: transaction, repository: nil)

        obj.stub :limit, 100 do
          err = assert_raises(Models::Transfers::AmountOverLimit) { obj.transfer }
          assert_equal "101 over transfer limit: 100", err.message
        end
      end

      def test_transfer_checks_for_external_failure
        transaction = Transaction.new({})
        obj = DummyTransfer.new(transaction: transaction, repository: nil)

        obj.stub :external_failure?, true do
          assert_raises(Models::Transfers::ExternalFailure) { obj.transfer }
        end
      end

      def test_invokes_repository_transfer
        transaction = Transaction.new(amount_in_cents: 3)
        repository = Minitest::Mock.new
        obj = DummyTransfer.new(transaction: transaction, repository: repository)

        repository.expect(:transfer, true, [transaction: transaction, commission: 5])

        obj.transfer
        repository.verify
      end
    end
  end
end
