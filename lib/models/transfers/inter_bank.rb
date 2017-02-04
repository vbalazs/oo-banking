module Models
  module Transfers
    class InterBank
      def commission
        500
      end

      def limit
        100_000
      end

      def external_failure?
        rand(100) + 1 <= 30
      end
    end
  end
end
