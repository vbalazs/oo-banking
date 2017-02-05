module Models
  class Account < Sequel::Model
    many_to_one :bank
  end
end
