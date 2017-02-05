module Models
  class Bank < Sequel::Model
    one_to_many :accounts
  end
end
