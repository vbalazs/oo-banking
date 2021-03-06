require "test_helper"

module Models
  module Transfers
    class IntraBankTest < Minitest::Test
      def test_initialization
        transfer = IntraBank.new(1, repository: 2)
        assert_equal 1, transfer.transaction
        assert_equal 2, transfer.repository
      end
    end
  end
end
