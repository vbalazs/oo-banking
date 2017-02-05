module Models
  module Transfers
    class IntraBank < Base
      def commission
        0
      end

      def limit
        BigDecimal::INFINITY
      end

      def external_failure?
        false
      end
    end
  end
end
