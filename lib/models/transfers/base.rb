module Models
  module Transfers
    class Base
      attr_reader :transaction, :repository

      def self.create_for(transaction, repository: Repositories::Transactions.new)
        if transaction.from_account.bank == transaction.to_account.bank
          IntraBank.new(transaction, repository: repository)
        else
          InterBank.new(transaction, repository: repository)
        end
      end

      def initialize(transaction, repository: Repositories::Transactions.new)
        @transaction = transaction
        @repository = repository
      end

      def fulfill
        if over_limit?
          raise AmountOverLimit,
            "#{amount} over transfer limit: #{limit}"
        end
        if external_failure?
          raise ExternalFailure,
            "External (random) failure happened"
        end

        repository.transfer(transaction: transaction, commission: commission)
      end

      def over_limit?
        amount > limit
      end

      protected

      def commission
        raise NotImplementedError, "This #{self.class} cannot respond to:"
      end

      def limit
        raise NotImplementedError, "This #{self.class} cannot respond to:"
      end

      def external_failure?
        raise NotImplementedError, "This #{self.class} cannot respond to:"
      end

      private

      def amount
        transaction.amount_in_cents.to_i
      end
    end

    class AmountOverLimit < StandardError; end
    class ExternalFailure < StandardError; end
  end
end
