class Game
  include Jongoid::Document

  field :user_id
  field :title

  field :board
  field :current_player

  field :opponent_id

  def get_number user_or_id
    user_or_id = user_or_id._id if user_or_id.is_a?(User)
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

  def reversed_board
    b = board.reverse
    b.map{|l| l.reverse }
  end

  def user_board an_user_or_id
    an_user_id = an_user_or_id.is_a?(User) ? an_user_or_id._id : an_user_or_id
    return reversed_board if self.user_id == an_user_id
    return board if self.opponent_id == an_user_id
    nil
  end

  def user
    User.find(user_id)
  end

  def to_json(*a)
    to_hash.merge({ user: user }).to_json(*a)
  end

  def turn(piece_old, piece_new, user)
    piece_new.map!(&:to_i)
    piece_old.map!(&:to_i)

    if self.user_id == user._id
      piece_old.map!{|p| 7 - p } 
      piece_new.map!{|p| 7 - p }
    end

    ox, oy = piece_old
    x, y = piece_new

    if (x-ox).abs != 1 && (y-oy).abs != 1
      return false if (x-ox).abs != 2 && (y-oy).abs != 2
    end

    if (x-ox).abs == 2 && (y-oy).abs == 2
      cx = (x+ox) / 2
      cy = (y+oy) / 2

      return false if board[cy][cx] != 3 - board[oy][ox]

      board[cy][cx] = 0
    end

    board[y][x] = board[oy][ox]
    board[oy][ox] = 0

    self.save
  end
end
