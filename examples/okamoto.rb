require "./lib/okamoto.rb"

curve = Ecc::Curve.new -1, 188, 983
pointG = Ecc::Point.new 1, 257
pointQ = Ecc::Point.new 243, 1

alice = Ecc::Okamoto.new curve, pointG, pointQ
bob   = Ecc::Okamoto.new curve, pointG, pointQ

puts ""
puts "alice set_secret and calculate_Ya============================================"
alice.set_secret_ka 293, 911
alice.calculate_Y
puts "k1, k2 = #{alice._k1}, #{alice._k2}"
puts "Y(x,y) = (#{alice._Y.x}, #{alice._Y.y})"

puts ""
puts "alice set_random_r and calculate_y==========================================="
alice.set_random_r 193, 499
alice.calculate_y
puts "r1,r2 = #{alice._r1}, #{alice._r2}"
puts "y = (#{alice._y.x}, #{alice._y.y})"

puts ""
puts "1. alice send_to bob========================================================="
alice.send_to bob, {_Y: alice._Y, _y: alice._y}
puts "Y(x,y) = (#{alice._Y.x}, #{alice._Y.y}), y = (#{alice._y.x}, #{alice._y.y})"

puts ""
puts "2. bob set_random_x and send to alice========================================"
bob.generate_rand_x 17
bob.send_to alice, {_x: bob._x }
puts "x = #{bob._x}"

puts ""
puts "3. alice calculate_ys and send to bob========================================"
alice.calculate_ys
alice.send_to bob, {_y1: alice._y1, _y2: alice._y2}
puts "y1 = (#{alice._y1})"
puts "y2 = (#{alice._y2})"

puts bob.run_check ? "Successful" : "Fail"
