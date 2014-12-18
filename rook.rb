class Rook < SlidingPiece

  SYMBOL = { black: "\u265C", white: "\u2656" }

  def symbol
    SYMBOL
  end

  private

  DELTAS = [[-1, 0], [0, 1], [1, 0], [0, -1]]

  def deltas
    DELTAS
  end

end
