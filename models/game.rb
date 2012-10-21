class Game
  include Jongoid::Document

  field :user_id
  field :title

  field :board
  field :current_player

  field :opponent_id

  def get_number user_or_id
    user_or_id = user_or_id._id if user_or_id.is_a(User)
    user_or_id == user_or_id ? 1 : 2
  end

  def init_board
    self.board = 8.times.map{Array.new(8, 0)}

    3.times do |y|
      4.times do |x|
        board[y][x*2+(y%2)] = 1
        board[7-y][x*2+((y+1)%2)] = 2
      end
    end

    self.current_player = rand(2) + 1
  end

  def user
    User.find(user_id)
  end

  def to_json(*a)
    to_hash.merge({ user: user }).to_json(*a)
  end

end
