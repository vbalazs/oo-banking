require "test_helper"

module Models
  class TestBank < Minitest::Test
    def test_initialization
      bank = Bank.new(name: "Alpha")
      assert_equal "Alpha", bank.name
    end
  end
end
