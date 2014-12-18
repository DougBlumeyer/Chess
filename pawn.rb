class Pawn < Piece

  SYMBOL = { black: "\u265F", white: "\u2659" }

  def symbol
    SYMBOL
  end

  def moves
    row, col = @pos[0], @pos[1]

    moves = advances + attacks

    moves.select { |move| @board.on_board?(move) }
  end

  private

  def at_start_row?
    @pos[0] == ((self.color == :black) ? 1 : 6)
  end

  def forward_dir
    (color == :black) ? 1 : -1
  end

  def advances
    moves = []
    row, col = @pos[0], @pos[1]

    moves << [row + 1 * forward_dir, col]
    moves << [row + 2 * forward_dir, col] if at_start_row?

    moves.select { |pos| @board.on_board?(pos) && @board[pos].nil? }
  end

  def attacks
    moves = []
    row, col = @pos[0], @pos[1]

    [[row + 1 * forward_dir, col + 1], [row + 1 * forward_dir, col - 1]]
    .each do |pos|
      moves << pos if @board.occupied_by_color?(pos, other_color)
    end

    moves
  end

end
