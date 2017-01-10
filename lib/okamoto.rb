require "./lib/curve.rb"

module Ecc
  class Okamoto
    attr_accessor :curve, :pointG, :pointQ,
                  :_n, :_Y, :_x, :_y, :_y1, :_y2,
                  :_k1, :_k2
    attr_reader   :_r1, :_r2

    def initialize(curve, pointG, pointQ)
      @curve    = curve
      @pointG   = pointG
      @pointQ   = pointQ
      @_n       = point_count
    end

    def point_count
      count = 1
      cur_point = Point.new(pointG.x, pointG.y)
      @curve.fp.times do |k|
        begin
          np_point = @curve.mod_mult cur_point, k + 1
          count += 1
        rescue ZeroDivisionError
          return count
        end
      end
      count
    end

    def send_to(sub, data = {})
      data.each do |key, val|
        eval "sub.#{key.to_s} = val"
      end
    end

    def set_secret_ka(_k1 = nil, _k2 = nil)
      @_k1 = _k1.nil? ? rand(1..self._n - 1) : _k1
      @_k2 = _k2.nil? ? rand(1..self._n - 1) : _k2
    end

    def set_random_r(_r1 = nil, _r2 = nil)
      @_r1 = _r1.nil? ? rand(1..self._n - 1) : _r1
      @_r2 = _r2.nil? ? rand(1..self._n - 1) : _r2
    end

    def generate_rand_x(_x = nil)
      @_x = _x.nil? ? rand(1..self._n - 1) : _x
    end

    def calculate_Y
      k1G = @curve.mod_mult @pointG, @_k1
      k2Q = @curve.mod_mult @pointQ, @_k2
      @_Y = @curve.mod_add k1G, k2Q
    end

    def calculate_y
      r1G = @curve.mod_mult @pointG, @_r1
      r2Q = @curve.mod_mult @pointQ, @_r2
      @_y = @curve.mod_add r1G, r2Q
    end

    def calculate_ys
      @_y1 = (@_r1 + @_k1 * @_x) % @_n
      @_y2 = (@_r2 + @_k2 * @_x) % @_n
    end

    def run_check
      p1 = @curve.mod_mult @pointG, @_y1
      p2 = @curve.mod_mult @pointQ, @_y2
      p3 = @curve.mod_mult @_Y, @_x
      p4 = @curve.mod_add p1, p2
      res = @curve.mod_sub p4, p3
      res == @_y
    end
  end
end
