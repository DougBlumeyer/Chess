class Bishop < SlidingPiece

  SYMBOL = { black: "\u265D", white: "\u2657" }

  def symbol
    SYMBOL
  end

  private

  DELTAS = [[-1, -1], [-1, 1], [1, 1], [1, -1]]

  def deltas
    DELTAS
  end

end
