require "test_helper"

module Models
  module Transfers
    # rubocop:disable Style/SingleLineMethods
    class DummyTransfer < Base
      def commission; 5; end
      def limit; 1000; end
      def external_failure?; false; end
    end
    # rubocop:enable Style/SingleLineMethods

    class BaseTest < SequelTestCase
      def setup
        @accounts_repository = Repositories::Accounts.new
      end

      def test_factory_method_same_bank
        bank = Bank.create(name: "X")
        account1 = @accounts_repository.create(name: "A", bank: bank)
        account2 = @accounts_repository.create(name: "B", bank: bank)
        transaction = Transaction.new(from_account: account1, to_account: account2)
        object = Base.create_for(transaction)

        assert_kind_of IntraBank, object
      end

      def test_factory_method_different_bank
        bank1 = Bank.create(name: "X")
        bank2 = Bank.create(name: "Y")
        account1 = @accounts_repository.create(name: "A", bank: bank1)
        account2 = @accounts_repository.create(name: "B", bank: bank2)
        transaction = Transaction.new(from_account: account1, to_account: account2)
        object = Base.create_for(transaction)

        assert_kind_of InterBank, object
      end

      def test_over_limit
        transaction = Transaction.new(amount_in_cents: 101)
        obj = DummyTransfer.new(transaction, repository: nil)

        obj.stub :limit, 100 do
          assert_equal true, obj.over_limit?
        end
      end

      def test_fulfill_checks_for_limit
        transaction = Transaction.new(amount_in_cents: 101)
        obj = DummyTransfer.new(transaction, repository: nil)

        obj.stub :limit, 100 do
          err = assert_raises(Models::Transfers::AmountOverLimit) { obj.fulfill }
          assert_equal "101 over transfer limit: 100", err.message
        end
      end

      def test_fulfill_checks_for_external_failure
        transaction = Transaction.new({})
        obj = DummyTransfer.new(transaction, repository: nil)

        obj.stub :external_failure?, true do
          assert_raises(Models::Transfers::ExternalFailure) { obj.fulfill }
        end
      end

      def test_invokes_repository_transfer
        transaction = Transaction.new(amount_in_cents: 3)
        repository = Minitest::Mock.new
        obj = DummyTransfer.new(transaction, repository: repository)

        repository.expect(:transfer, true, [transaction: transaction, commission: 5])

        obj.fulfill
        repository.verify
      end
    end
  end
end
