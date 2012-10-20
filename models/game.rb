class Game
  include Jongoid::Document

  field :board
  field :current_player

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

end