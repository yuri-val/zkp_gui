module Ecc
  class Log
    attr_accessor :a, :b, :n

    @@primes = {}

    def initialize (a, b, n)
      @a      = a
      @b      = b
      @n      = n
      @fn     = Log.eiler n
    end

    def self.pow_mod (a, b, n)
      if b > 0
        a ** b % n
      else
        (a ** -b % n) ** (Log.eiler(n) - 1) % n
      end
    end

    def baby_step_giant_step
      unless Log.is_prime @n and self.is_generator @a
        puts "n is not prime or a is not a generator"
        return nil
      end

      h = Math.sqrt(@n).floor() + 1
      c = Log.pow_mod @a, h, @n

      list_1 = []
      for i in (1..h)
        list_1.push Log.pow_mod(c, i, @n)
      end

      for j in (1..h)
        element = (@b * (@a ** j)) % @n
        i = list_1.index element
        unless i.nil?
          return h * (i + 1) - j
        end
      end
      nil
    end

    # algorithm of Gauss
    def chinese_remainder_theorem (num, remainders)
      x = 0
      for remainder in remainders
        y = num / remainder[1]
        s = Log.pow_mod y, -1, remainder[1]
        c = remainder[0] * s % remainder[1]
        x += c * y % num
      end
      x
    end

    def polig_hellman
      unless Log.is_prime @n and self.is_generator @a
        puts "n is not prime or a is not a generator"
        return nil
      end

      factors = Log.factor @n - 1
      remainders = []
      for factor in factors
        q     = factor[0]
        alpha = factor[1]
        num   = q ** alpha

        c = Log.pow_mod @a, (@n - 1) / q, @n

        list = [1]
        for i in (1...q)
          list.push Log.pow_mod(c, i, @n)
        end

        remainder = 0
        for i in (0...alpha)
          x = Log.pow_mod @b * Log.pow_mod(@a, - remainder, @n), (@n - 1) / (q ** (i + 1)), @n
          x = list.index x
          remainder += x * Log.pow_mod(q, i, @n)
        end
        remainders.push [remainder, num]
      end
      chinese_remainder_theorem @n - 1, remainders
    end

    def brute
      res = []
      for i in (1..@fn)
        if ((@a ** i) - @b) % @n == 0
          res.push i
        end
      end
      res
    end

    # is a a generator of the cyclic group Zp?
    def is_generator (a)
      factors = Log.factor @n - 1
      for factor in factors
        if Log.pow_mod(a, (@n - 1) / factor[0], @n) == 1
          return false
        end
      end
      true
    end

    # get a random generator of the cyclic group Zp
    def random_generator ()
      a = Time.now.usec
      while not self.is_generator(a)
        a += 1
      end
      a
    end

    def self.eiler (num)
      factors = Log.factor num
      res = num
      for factor in factors
        res *= 1 - 1.0 / factor[0]
      end
      res.floor
    end

    def self.factor (num)
      factors = []
      length = Math.sqrt(num).floor

      for i in (2..length)
        if num % i == 0
          if Log.is_prime(i)
            k = 1
            num_copy = num / i
            while num_copy % i == 0
              num_copy /= i
              k += 1
            end
            factors.push [i, k]
          end
          j = num / i
          if j != i
            if Log.is_prime(j)
              k = 1
              num_copy = num / j
              while num_copy % j == 0
                num_copy /= j
                k += 1
              end
              factors.push [j, k]
            end
          end
        end
      end

      if factors.length == 0
        @@primes[num] = true
        [[num, 1]]
      else
        @@primes[num] = false
        factors
      end
    end

    def self.is_prime (num)
      unless @@primes.has_key? num
        Log.factor num
      end
      @@primes[num]
    end
  end
end
