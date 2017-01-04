module Ecc
  class Point
    attr_reader :inf, :x, :y

    # Creates a point x, y, where x and y can be Infinity.
    def initialize (x, y)
      if x == Float::INFINITY and y == Float::INFINITY
        @inf = true
      else
        @inf = false
      end

      @x = x
      @y = y
    end

    def ==(other)
      self.x == other.x && self.y == other.y
    end

    def to_s
      "{" + @x.to_s + ", " + @y.to_s + "}"
    end
  end
end
