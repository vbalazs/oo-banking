require "test_helper"

module Models
  class BankTest < SequelTestCase
    def test_initialization
      bank = Bank.create(name: "Alpha")
      assert_equal "Alpha", bank.name
    end
  end
end
