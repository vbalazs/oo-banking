module Models
  class Transaction < Sequel::Model
    many_to_one :from_account, class: :"Models::Account"
    many_to_one :to_account, class: :"Models::Account"
  end
end
