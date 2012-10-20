class GameController < Controller
  # def new_game
  #   game = Game.find(params[:id])
  #   game.board
  # end

  # def save_game
  #   game = Game.new
  #   game.init_board
  #   game.save
  #   game.id
  # end

  def action_send
    until api_receivers.empty? do
      receiver = api_receivers.shift
      receiver.resume('ololo')
    end
    'sent )'
  end

  def action_recv
    api_receivers << Fiber.current

    Fiber.yield
  end

  def sign_in
    username = params['username'].strip

    user = User.first(username: username)

    return user.inspect

    user = User.new
    user.username = username
    user.inspect
  end

private

  def api_receivers
    api_data['receivers'] ||= []
  end
end
