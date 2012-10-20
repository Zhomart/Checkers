class GameController < Controller
  # def action_send
  #   until api_receivers.empty? do
  #     receiver = api_receivers.shift
  #     receiver.resume('ololo')
  #   end
  #   'sent )'
  # end

  # def action_recv
  #   api_receivers << Fiber.current

  #   Fiber.yield
  # end

  def sign_in
    name = params['username']
    username = params['username'].strip[0..12].downcase

    if username.size < 3
      return { result: 'error', message: "username is too short" }.to_json
    end

    user = User.first(username: username)

    if user
      # if user.signed_in_at && user.signed_in_at + 10.minutes >= Time.now.to_i
      #   return {result: 'error', message: "'#{username}' is signed in, please wait for 10 minutes"}.to_json
      # end
    else
      user = User.new username: username, name: name
      user.save
    end

    user.update_user_sign_in

    ok_result user: user
  end

  def new_game
    return error_result("unknown user") if not params['user_id']

    game = Game.new user_id: params['user_id'], title: params['title']
    game.init_board
    game.save

    until api_game_list_receivers.empty? do
      receiver = api_game_list_receivers.shift
      receiver.resume game
    end
    
    ok_result game: game
  end

  def game_list
    return Game.all if params['all'] == 'true'

    api_game_list_receivers << Fiber.current
    Fiber.yield

    Game.all
  end

  def user_info
    ok_result user: User.find(_id: params['_id'])
  end

private
  def make_result(status, other_data_or_message)
    return {result: 'ok'}.merge(other_data_or_message).to_json if status
    { result: 'error', message: other_data_or_message }.to_json
  end

  def error_result(message)
    make_result false, message
  end

  def ok_result(data)
    make_result true, data
  end

  def api_game_list_receivers
    api_data['game_list_receivers'] ||= []
  end
end
