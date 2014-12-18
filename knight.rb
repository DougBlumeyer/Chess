class Knight < SteppingPiece

  SYMBOL = { black: "\u265E", white: "\u2658" }

  def symbol
    SYMBOL
  end

  private

  DELTAS = [-2, -1, 1, 2].permutation(2).reject { |perm| perm.inject(:+) == 0 }

  def deltas
    DELTAS
  end

end
