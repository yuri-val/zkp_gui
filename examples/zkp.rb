require "./lib/zkp.rb"

curve = Ecc::Curve.new -1, 188, 751
pointG = Ecc::Point.new 1, 375
pointQ = Ecc::Point.new 2, 373

alice = Ecc::ZKP.new curve, pointG, pointQ
bob   = Ecc::ZKP.new curve, pointG, pointQ

puts ""
puts "alice set_secret and calculate_Ya============================================"
alice.set_secret_ka 327, 715
alice.calculate_Ya
puts "k1, k2 = #{alice._k1}, #{alice._k2}"
puts "Ya(x,y) = (#{alice._Ya.x}, #{alice._Ya.y})"

puts ""
puts "bob set_secret and calculate_Yb=============================================="
bob.set_secret_kb 496
bob.calculate_Yb
puts "kb = #{bob._kb}"
puts "Yb(x,y) = (#{bob._Yb.x}, #{bob._Yb.y})"

puts ""
puts "alice set_random_r and calculate_y==========================================="
alice.set_random_r 619, 157
alice.calculate_y
puts "r1,r2 = #{alice._r1}, #{alice._r2}"
puts "y = (#{alice._y.x}, #{alice._y.y})"

puts ""
puts "1. alice send_to bob========================================================="
alice.send_to bob, {_Ya: alice._Ya, _y: alice._y}
puts "Ya(x,y) = (#{alice._Ya.x}, #{alice._Ya.y}), y = (#{alice._y.x}, #{alice._y.y})"

puts ""
puts "2. bob set_random_x and send to alice========================================"
bob.generate_rand_x 191
bob.send_to alice, {_Yb: bob._Yb, _x: bob._x }
puts "Yb(x,y) = (#{bob._Yb.x}, #{bob._Yb.y}), x = #{bob._x}"

puts ""
puts "3. alice calculate_ys and send to bob========================================"
alice.calculate_ys
alice.send_to bob, {_y1: alice._y1, _y2: alice._y2, _y3: alice._y3}
puts "y1 = (#{alice._y1.x} ,#{alice._y1.y})"
puts "y2 = (#{alice._y2.x} ,#{alice._y2.y})"
puts "y3 = (#{alice._y3.x} ,#{alice._y3.y})"

puts bob.run_check ? "Successful" : "Fail"
