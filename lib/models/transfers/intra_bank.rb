module Models
  module Transfers
    class IntraBank
      def commission
        0
      end

      def limit
        0
      end

      def external_failure?
        false
      end
    end
  end
end
