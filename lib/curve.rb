require "./lib/point"

module Ecc
  class Curve
    attr_reader   :fp
    # Creates an elliptic curve of the form
    #
    # y^2 = x^3 + ax + b
    #
    # over the field fp
    #
    # Although it is not explicitly checked, it should be
    # noted that operations work best over curves which are
    # non-singular, ergo the discriminant of the curve,
    # ∆ = 4a^3+27b^2, should be non-zero
    #
    # Also note that for proper security, fp should be
    # a relatively large number and preferably prime,
    # as to avoid any problems with Lenstra factorization
    def initialize (a, b, fp)
      @a  = a
      @b  = b
      @fp = fp
    end

    # Computes module for both positive and negative numbers
    def self.mod (a, b)
      ((a % b) + b) % b
    end

    # Computes the solutions to the equation
    # ax + by = gcd(a, b)
    # where a and b are given.
    def self.ext_gcd (a, b)
      lx = 0; ly = 1; x  = 1; y  = 0;

      while(b != 0)
          r = mod(a, b);
          q = (a - r) / b;
          tmpx = x;
          tmpy = y;

          x = lx - (q*x);
          lx = tmpx;

          y = ly - (q*y);
          ly = tmpy;

          a = b;
          b = r;
      end

      return [ly, lx];
    end

    # Computes the solution to equations of the form
    # a/b = x (mod p)
    # where a, b are given and p = Fp
    def mod_inv (a, b, base = nil)
      base = base.nil? ? @fp : base
      res = Curve.ext_gcd b, base
      dis = res[1]
      x   = (a - (base * dis * a)) / b

      Curve.mod x, base
    end

    # Subtracts two points on the curve
    # See mod_add below for a description of the algorithm
    def mod_sub (a, b)
      self.mod_add a, Ecc::Point.new(b.x, -b.y)
    end

    # Adds two points on the curve
    def mod_add (a, b)
      if b.inf
        return a
      end
      if a.inf
        return b
      end

      x1 = a.x
      x2 = b.x
      y1 = a.y
      y2 = b.y

      if x1 == x2 and y1 == -y2
        return Point.new Float::INFINITY, Float::INFINITY
      end

      if x1 == x2 and y1 == y2
        lambda = self.mod_inv 3 * x1 ** 2 + @a, 2 * y1
      else
        lambda = self.mod_inv y2 - y1, x2 - x1
      end

      x3 = Curve.mod lambda ** 2 - x1 - x2,   @fp
      y3 = Curve.mod lambda * (x1 - x3) - y1, @fp

      Ecc::Point.new x3, y3
    end

    # Adds a point on the curve, P, to itself n times
    # This has been implemented using the Double-and-Add algorithm.
    def mod_mult (p, n)
      q = p
      r = Point.new Float::INFINITY, Float::INFINITY

      while n > 0
        if n % 2 == 1
          r = self.mod_add r, q
        end

        q = self.mod_add q, q
        n = (n / 2).floor
      end
      r
    end
  end
end
