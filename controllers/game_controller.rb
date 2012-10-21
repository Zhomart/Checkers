class GameController < Controller
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

    ok_result game_id: game._id
  end

  def game_list
    return available_games if params['all'] == 'true'

    api_game_list_receivers << Fiber.current
    Fiber.yield

    available_games
  end

  def user_info
    ok_result user: User.find(_id: params['_id'])
  end

  def get_opponent
    api_opponent_receivers << { fiber: Fiber.current, user_id: params['user_id'], game_id: params['game_id']}

    until api_game_list_receivers.empty? do
      receiver = api_game_list_receivers.shift
      receiver.resume nil
    end

    ok_result opponent: Fiber.yield, number: 1
  end

  def start_game
    game = Game.find(params['game_id'])
    user = User.find(params['user_id'])

    opponent = api_opponent_receivers.detect{|o| o[:game_id] == game._id }

    return error_result 'game not found' if not opponent

    game.opponent_id = user._id
    game.save

    opponent[:fiber].resume user

    api_opponent_receivers.delete opponent

    until api_game_list_receivers.empty? do
      receiver = api_game_list_receivers.shift
      receiver.resume nil
    end

    ok_result game_id: game._id, opponent: game.user, number: 2
  end

  def cancel_game
    api_opponent_receivers.delete_if{|r| r[:game_id] == params['game_id']}

    until api_game_list_receivers.empty? do
      receiver = api_game_list_receivers.shift
      receiver.resume nil
    end
  end

  def game_info
    raise "incorrect input data" if not (params['game_id'] || params['user_id'])
    game = Game.find(params['game_id'])
    board = game.user_board params['user_id']
    raise "unknown user" if not board

    # p "#{game.current_player} #{game.user_id} #{game.opponent_id} #{params['user_id']}"
    # print board.map(&:to_s).join("\n")

    ok_result :board => board, :current_player => game.current_player
  end

  def turn_done
    game = Game.find params['game_id']
    user = User.find params['user_id']

    game.turn params['old'], params['new'], user

    until api_opponent_turn_receivers.empty?
      op = api_opponent_turn_receivers.shift
      next if op[:game_id] != game._id
      board = game.user_board op[:user_id]
      op[:fiber].resume ok_result(board: board)
    end

    ok_result board: game.user_board(user)
  end

  def wait_for_opponents_turn
    api_opponent_turn_receivers << { fiber: Fiber.current, game_id: params['game_id'], user_id: params['user_id'] }
    Fiber.yield
  end

private
  def available_games
    games = Game.all.select do |game|
      api_opponent_receivers.detect{|r| r[:game_id] == game._id }
    end
    games.map{|g| {_id: g._id, title: g.title, username: g.user.name } }
  end

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

  def api_opponent_receivers
    api_data['opponent_receivers'] ||= []
  end

  def api_opponent_turn_receivers
    api_data['opponent_turn_receivers'] ||= []
  end

end
