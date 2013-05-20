class GameController < Controller
  def sign_in
    name = params['username']
    username = params['username'].strip[0..12].downcase

    log "sign_in 1"

    if username.size < 3
      return { result: 'error', message: "username is too short" }.to_json
    end

    user = User.first(username: username)

    if user
      if user.signed_in_at && user.signed_in_at + 10.minutes >= Time.now.to_i
        log "sign_in 2"
        return {result: 'error', message: "'#{username}' is signed in, please wait for 10 minutes"}.to_json
      end
    else
      user = User.new username: username, name: name
      user.save
    end

    user.update_user_sign_in

    log "sign_in 3"

    ok_result user: user
  end

  def new_game
    return error_result("unknown user") if not params['user_id']

    game = Game.new user_id: params['user_id'], title: params['title']
    game.init_board
    game.save

    log "new_game"

    ok_result game_id: game._id
  end

  def game_list
    log "game_list 1"
    return available_games if params['all'] == 'true'

    log "game_list 2"

    api_game_list_receivers << Fiber.current
    Fiber.yield

    log "game_list 3"

    available_games
  end

  def user_info
    log "user_info"
    ok_result user: User.find(_id: params['_id'])
  end

  def get_opponent
    log "get_opponent 1"

    api_opponent_receivers << { fiber: Fiber.current, user_id: params['user_id'], game_id: params['game_id']}

    log "get_opponent 2"

    until api_game_list_receivers.empty? do
      receiver = api_game_list_receivers.shift
      receiver.resume nil
    end

    log "get_opponent 3"

    op = ok_result opponent: Fiber.yield, number: 1
    log "get_opponent 4"
    op
  end

  def start_game
    log "start_game 1"

    game = Game.find(params['game_id'])
    user = User.find(params['user_id'])

    opponent = api_opponent_receivers.detect{|o| o[:game_id] == game._id }

    log "start_game 2"

    return error_result 'game not found' if not opponent

    game.opponent_id = user._id
    game.save

    opponent[:fiber].resume user

    api_opponent_receivers.delete opponent

    log "start_game 3"

    until api_game_list_receivers.empty? do
      receiver = api_game_list_receivers.shift
      receiver.resume nil
    end

    log "start_game 4"

    ok_result game_id: game._id, opponent: game.user, number: 2
  end

  def cancel_game
    log "cancel_game 1"

    api_opponent_receivers.delete_if{|r| r[:game_id] == params['game_id']}

    log "cancel_game 2"

    until api_game_list_receivers.empty? do
      receiver = api_game_list_receivers.shift
      receiver.resume nil
    end

    log "cancel_game 3"
  end

  def game_info
    log "game_info 1"
    raise "incorrect input data" if not (params['game_id'] || params['user_id'])
    game = Game.find(params['game_id'])
    board = game.user_board params['user_id']
    raise "unknown user" if not board

    log "game_info 2"
    ok_result :board => board, :current_player => game.current_player
  end

  def turn_done
    log "turn_done 1"
    game = Game.find params['game_id']
    user = User.find params['user_id']

    game.turn params['old'], params['new'], user

    log "turn_done 2"
    until api_opponent_turn_receivers.empty?
      op = api_opponent_turn_receivers.shift
      next if op[:game_id] != game._id
      board = game.user_board op[:user_id]
      op[:fiber].resume ok_result(board: board)
    end

    log "turn_done 3"
    ok_result board: game.user_board(user)
  end

  def wait_for_opponents_turn
    log "wait_for_opponents_turn 1"
    api_opponent_turn_receivers << { fiber: Fiber.current, game_id: params['game_id'], user_id: params['user_id'] }
    log "wait_for_opponents_turn 2"
    ff = Fiber.yield
    log "wait_for_opponents_turn 3"
    ff
  end

private
  def log(*a)
    user = User.find(params['user_id'].to_s)
    print "#{user.name}: " if user
    p *a
  end

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
