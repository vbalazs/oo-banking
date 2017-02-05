class SequelTestCase < Minitest::Test
  def run(*args, &block)
    Sequel::Model.db.transaction(rollback: :always, auto_savepoint: true){ super }
  end
end
