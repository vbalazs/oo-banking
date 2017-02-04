module Models
  module Transfers
    class Base
      attr_reader :transaction, :repository

      def initialize(transaction: , repository: )
        @transaction = transaction
        @repository = repository
      end

      def transfer
        raise AmountOverLimit,
          "#{amount} over transfer limit: #{limit}"  if amount > limit
        raise ExternalFailure,
          "External (random) failure happened" if external_failure?

        repository.transfer(transaction, commission: commission)
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
