require "rubygems"

APP_ROOT = Bundler.root
$LOAD_PATH.unshift(APP_ROOT.join("db").to_s, APP_ROOT.join("lib").to_s)

require "connection"
require "eager_load"

class App
  attr_reader :logger
  def initialize(logger: Logger.new(STDOUT))
    @jim = Models::Account.first(name: "Jim's account")
    @emma = Models::Account.first(name: "Emma's account")
    @logger = logger
  end

  def run
    logger.info "Initial status: Jim: #{(@jim.balance_in_cents / 100).to_s('F')} €;
      Emma: #{(@emma.balance_in_cents / 100).to_s('F')} €"

    agent = TransferAgent.new(from_account: @jim, to_account: @emma, amount_in_cents: 2_000_000,
      logger: logger)

    agent.execute

    logger.info "After transaction: Jim: #{(@jim.refresh.balance_in_cents / 100).to_s('F')} €;
      Emma: #{(@emma.refresh.balance_in_cents / 100).to_s('F')} €"
  end
end

App.new.run
