require_rel '../lib/'

class ZKP
  include GladeGUI

  def b_set_EC__clicked(*_args)
    params = @builder['entry1'].text.split(',')
    if params.size != 3
      alert 'Должно быть 3 параметра: p, a, b'
      return
    end
    begin
      _p = params[0]
      _a = params[1]
      _b = params[2]

      new_label = '     y² = (x³ + ax + b) mod p'
      new_label.gsub!('p', _p.to_s).gsub!('a', _a.to_s).gsub!('b', _b.to_s)
      @curve = Ecc::Curve.new _a.to_i, _b.to_i, _p.to_i
      @builder['label2'].label = new_label
    rescue
      alert 'Должно быть 3 параметра: p, a, b'
      return
    end
  end

  def b_set_params__clicked(*_args)
    paramsG = @builder['entry2'].text.split(',')
    paramsQ = @builder['entry3'].text.split(',')
    g_x = paramsG[0]
    g_y = paramsG[1]
    q_x = paramsQ[0]
    q_y = paramsQ[1]

    if g_x.nil? || g_y.nil? || q_x.nil? || q_y.nil?
      alert 'Проверьте заполнение параметров'
      return
    end

    begin
    pointG = Ecc::Point.new g_x.to_i, g_y.to_i
    pointQ = Ecc::Point.new q_x.to_i, q_y.to_i

    @alice = Ecc::ZKP.new @curve, pointG, pointQ
    @bob   = Ecc::ZKP.new @curve, pointG, pointQ

    @builder['entry4'].text = @alice._n.to_s
    rescue
      alert 'Проверьте заполнение параметров'
      return
    end
  end

  def b_get_keys__clicked(*_args)
    @alice.set_secret_ka
    @builder['entry5'].text = @alice._k1.to_s
    @builder['entry6'].text = @alice._k2.to_s

    @bob.set_secret_kb
    @builder['entry7'].text = @bob._kb.to_s
    calculate_Y
  end

  def b_set_keys__clicked(*_args)
    k1 = @builder['entry5'].text.to_i
    k2 = @builder['entry6'].text.to_i
    kb = @builder['entry7'].text.to_i

    @alice.set_secret_ka k1, k2

    @bob.set_secret_kb kb
    calculate_Y
  end

  def calculate_Y
    @alice.calculate_Ya
    @bob.calculate_Yb
    val_Ya = 'Ya = (Yax; Yay)'
    val_Yb = 'Yb = (Ybx; Yby)'
    val_Ya.gsub!('Yax', @alice._Ya.x.to_s).gsub!('Yay', @alice._Ya.y.to_s)
    val_Yb.gsub!('Ybx', @bob._Yb.x.to_s).gsub!('Yby', @bob._Yb.y.to_s)
    @builder['label14'].label = val_Ya
    @builder['label15'].label = val_Yb
  end

  def b_get_rand_r__clicked(*_args)
    @alice.set_random_r
    @builder['entry10'].text = @alice._r1.to_s
    @builder['entry11'].text = @alice._r2.to_s
  end

  def b_set_rand_r__clicked(*_args)
    r1 = @builder['entry10'].text.to_i
    r2 = @builder['entry11'].text.to_i

    @alice.set_random_r r1, r2
  end

  def b_calc_y__clicked(*_args)
    val_y = 'Ɣ = (Ɣx, Ɣy)'
    @alice.calculate_y
    val_y.gsub!('Ɣx', @alice._y.x.to_s).gsub!('Ɣy', @alice._y.y.to_s)
    @builder['label20'].label = val_y
  end

  def b_send_to_b_1__clicked(*_args)
    @alice.send_to @bob, _Ya: @alice._Ya, _y: @alice._y

    val_Ya = 'Ya = (Yax; Yay)'
    val_y = 'Ɣ = (Ɣx, Ɣy)'

    val_Ya.gsub!('Yax', @bob._Ya.x.to_s).gsub!('Yay', @bob._Ya.y.to_s)
    val_y.gsub!('Ɣx', @bob._y.x.to_s).gsub!('Ɣy', @bob._y.y.to_s)

    @builder['label21'].label = val_Ya
    @builder['label22'].label = val_y
  end

  def b_get_x__clicked(*_args)
    @bob.generate_rand_x
    @builder['entry8'].text = @bob._x.to_s
  end

  def b_set_x__clicked(*_args)
    x = @builder['entry8'].text.to_i

    @bob.generate_rand_x x
  end

  def b_send_to_a_1__clicked(*_args)
    @bob.send_to @alice, _Yb: @bob._Yb, _x: @bob._x

    val_Yb = 'Yb = (Ybx; Yby)'
    val_x  = 'x'
    val_Yb.gsub!('Ybx', @alice._Yb.x.to_s).gsub!('Yby', @alice._Yb.y.to_s)
    val_x.gsub!('x', @alice._x.to_s)

    @builder['label25'].label = val_Yb
    @builder['label26'].label = val_x
  end

  def b_calc_ys__clicked(*_args)
    @alice.calculate_ys

    y1 = 'y1 = (y1x; y1y)'
    y2 = 'y2 = (y2x; y2y)'
    y3 = 'y3 = (y3x; y3y)'

    y1.gsub!('y1x', @alice._y1.x.to_s).gsub!('y1y', @alice._y1.y.to_s)
    y2.gsub!('y2x', @alice._y2.x.to_s).gsub!('y2y', @alice._y2.y.to_s)
    y3.gsub!('y3x', @alice._y3.x.to_s).gsub!('y3y', @alice._y3.y.to_s)

    @builder['label28'].label = y1
    @builder['label29'].label = y2
    @builder['label30'].label = y3
  end

  def b_send_to_b_2__clicked(*_args)
    @alice.send_to @bob, _y1: @alice._y1, _y2: @alice._y2, _y3: @alice._y3

    y1 = 'y1 = (y1x; y1y)'
    y2 = 'y2 = (y2x; y2y)'
    y3 = 'y3 = (y3x; y3y)'

    y1.gsub!('y1x', @bob._y1.x.to_s).gsub!('y1y', @bob._y1.y.to_s)
    y2.gsub!('y2x', @bob._y2.x.to_s).gsub!('y2y', @bob._y2.y.to_s)
    y3.gsub!('y3x', @bob._y3.x.to_s).gsub!('y3y', @bob._y3.y.to_s)

    @builder['label31'].label = y1
    @builder['label32'].label = y2
    @builder['label33'].label = y3
  end

  def b_run_check__clicked(*_args)
    value = @bob.run_check ? 'Проверка успешна' : 'Ошибка при проверке'
    @builder['label34'].label = value
  end
end
