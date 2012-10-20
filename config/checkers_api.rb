environment(:development) do
  config['mongo'] = EventMachine::Synchrony::ConnectionPool.new(:size => 20) do
    session = Moped::Session.new(["127.0.0.1:27017"])
    session.use :kbtu_checkers
    session
  end
end
