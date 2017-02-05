class TransferAgentTest < SequelTestCase
  def setup
    @accounts_repo = Repositories::Accounts.new
    @bank_1 = Models::Bank.create(name: "test")
    @bank_2 = Models::Bank.create(name: "test 2")
    @null_logger = Logger.new(nil)
  end

  def test_execute_with_single_transaction
    account_1 = @accounts_repo.create(name: 'From', bank: @bank_1, balance_in_cents: 100)
    account_2 = @accounts_repo.create(name: 'To', bank: @bank_1)
    agent = TransferAgent.new(from_account: account_1, to_account: account_2,
      amount_in_cents: 100, logger: @null_logger)

    transactions = agent.execute

    assert_equal 1, transactions.count
    assert_equal 100, account_2.refresh.balance_in_cents
  end

  def test_execute_with_subtransactions
    account_1 = @accounts_repo.create(name: 'From', bank: @bank_1, balance_in_cents: 150_000)
    account_2 = @accounts_repo.create(name: 'To', bank: @bank_2)
    agent = TransferAgent.new(from_account: account_1, to_account: account_2,
      amount_in_cents: 101_000, logger: @null_logger)

    transactions = agent.execute

    assert_equal 2, transactions.count
    assert_equal [100_000, 1000], transactions.map(&:amount_in_cents)
    assert_equal 101_000, account_2.refresh.balance_in_cents
  end
end
