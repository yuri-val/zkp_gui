require "./lib/curve.rb"

module Ecc
  class ZKP
    attr_accessor :curve, :pointG, :pointQ,
                  :_n, :_Ya, :_Yb, :_x, :_y, :_y1, :_y2, :_y3,
                  :_k1, :_k2, :_kb
    attr_reader   :_r1, :_r2

    def initialize(curve, pointG, pointQ)
      @curve    = curve
      @pointG   = pointG
      @pointQ   = pointQ
      @_n       = point_count
    end

    def point_count
      count = 1
      cur_point = Point.new(@pointG.x, @pointG.y)
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

    def set_secret_kb(_kb = nil)
      @_kb = _kb.nil? ? rand(1..self._n - 1) : _kb
    end

    def set_random_r(_r1 = nil, _r2 = nil)
      @_r1 = _r1.nil? ? rand(1..self._n - 1) : _r1
      @_r2 = _r2.nil? ? rand(1..self._n - 1) : _r2
    end

    def generate_rand_x(_x)
      @_x = _x.nil? ? rand(1..self._n - 1) : _x
    end

    def calculate_Ya
      k1G = @curve.mod_mult @pointG, @_k1
      k2Q = @curve.mod_mult @pointQ, @_k2
      @_Ya = @curve.mod_add k1G, k2Q
    end

    def calculate_Yb
      @_Yb = @curve.mod_mult(@curve.mod_add(@pointG, @pointQ), @_kb)
    end

    def calculate_y
      r1G = @curve.mod_mult @pointG, @_r1
      r2Q = @curve.mod_mult @pointQ, @_r2
      @_y = @curve.mod_add r1G, r2Q
    end

    def calculate_ys
      @_y1 = @curve.mod_mult @_Yb, (@_r1 + (@_x * @_k1))
      @_y2 = @curve.mod_mult @_Yb, (@_r2 + (@_x * @_k2))
      @_y3 = @curve.mod_add(
              @curve.mod_mult(@pointQ, (@_r1 + (@_x * @_k1))),
              @curve.mod_mult(@pointG, (@_r2 + (@_x * @_k2))))
    end

    def run_check
      p1 = @curve.mod_add @_y1, @_y2
      p2 = @curve.mod_inv(1, @_kb, @_n)
      p @_kb, p2
      p3 = @curve.mod_mult p1, p2
      p4 = @curve.mod_sub p3, @_y3
      p5 = @curve.mod_mult @_Ya, @_x
      @curve.mod_sub p4, p5
    end
  end
end
