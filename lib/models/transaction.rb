module Models
  class Transaction
    attr_reader :from_account, :to_account, :amount_in_cents, :status
    def initialize(args)
      @from_account = args[:from_account]
      @to_account = args[:to_account]
      @amount_in_cents = args[:amount_in_cents]
      @status = args.fetch(:status, "queued")
    end
  end
end
