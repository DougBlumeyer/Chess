class Queen < SlidingPiece

  SYMBOL = { black: "\u265B", white: "\u2655" }

  def symbol
    SYMBOL
  end

  private

  DELTAS = [-1, 0, 1].repeated_permutation(2).to_a
  DELTAS.delete([0, 0])

  def deltas
    DELTAS
  end

end
