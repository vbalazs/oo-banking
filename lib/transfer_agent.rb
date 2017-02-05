require 'logger'

class TransferAgent
  attr_reader :logger, :from_account, :to_account, :amount_in_cents

  def initialize(from_account:, to_account:, amount_in_cents:, logger: Logger.new(STDOUT))

    @logger = logger
    @from_account = from_account
    @to_account = to_account
    @amount_in_cents = amount_in_cents
  end

  def execute
    logger.info "Transfer with agent: #{amount_in_cents} from #{from_account.name} \
      to #{to_account.name}"
    transferer = transfer_object(transaction(amount_in_cents))
    queue = []

    if transferer.over_limit?
      queue += subtransactions(amount_in_cents, transferer.limit)
    else
      queue.push(transferer.transaction)
    end

    queue.map { |t| retrying_transfer(t) }
  end

  def retrying_transfer(transaction)
    n = 0
    begin
      transfer_object(transaction).fulfill
    rescue Models::Transfers::ExternalFailure
      n +=1
      logger.warn "Transfer failed, retrying... ##{n}"
      retry if n < 10
      logger.error "Transfer failed, gave up"
    end
  end

  private

  def subtransactions(amount, limit)
    q, m = amount.divmod(limit)
    logger.info "Transfer is over limit, breaking it up: #{limit}*#{q}+#{m}"

    q.times.map { transaction(limit) }.push(transaction(m))
  end

  def transfer_object(transaction)
    Models::Transfers::Base.create_for(transaction)
  end

  def transaction(amount)
    Models::Transaction.new(from_account: from_account, to_account: to_account,
      amount_in_cents: amount)
  end
end
