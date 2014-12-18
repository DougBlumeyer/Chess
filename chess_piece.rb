class Piece
  attr_accessor :color, :pos, :board

  def initialize(board, pos, color)
    @board = board
    @pos = pos
    @color = color

    @board[@pos] = self
  end

  def valid_moves
    moves.reject { |move| move_into_check?(move) }
  end

  def move_into_check?(pos)
    duped_board = @board.dup
    duped_board.move!(@pos,pos)

    return duped_board.in_check?(self.color)
  end

  private

  def other_color
    self.color == :black ? :white : :black
  end

end
