module Models
  class Account < Sequel::Model
    many_to_one :bank

    def formatted_balance
      format("%.2f €", (balance_in_cents / 100).truncate(2))
    end
  end
end
