require_rel '../lib/'

class ZKP #(change name)
  
  include GladeGUI

  def b_set_EC__clicked(*args)
    params = @builder["entry1"].text.split(',')
    if params.size < 3 
      return
    end
    _p = params[0].to_i
    _a = params[1].to_i
    _b = params[2].to_i
  
    new_label = '     y² = (x³ + ax + b) mod p'
    new_label.gsub!('p', _p.to_s).gsub!('a', _a.to_s).gsub!('b', _b.to_s) 
    @curve = Ecc::Curve.new _a, _b, _p
    @builder["label2"].label = new_label    
  end

  def b_set_params__clicked(*args)
    paramsG = @builder["entry2"].text.split(',')
    paramsQ = @builder["entry3"].text.split(',')
    g_x, g_y = paramsG[0].to_i, paramsG[1].to_i
    q_x, q_y = paramsQ[0].to_i, paramsQ[1].to_i

    pointG = Ecc::Point.new g_x, g_y
    pointQ = Ecc::Point.new q_x, q_y

    @alice = Ecc::ZKP.new @curve, pointG, pointQ
    @bob   = Ecc::ZKP.new @curve, pointG, pointQ

    @builder["entry4"].text = @alice._n.to_s
  end

  def b_get_keys__clicked(*args)
    @alice.set_secret_ka
    @builder["entry5"].text = @alice._k1.to_s
    @builder["entry6"].text = @alice._k2.to_s

    @bob.set_secret_kb 
    @builder["entry7"].text = @bob._kb.to_s
  end

  def b_set_keys__clicked(*args)
    k1 = @builder["entry5"].text.to_i    
    k2 = @builder["entry6"].text.to_i    
    kb = @builder["entry7"].text.to_i    

    @alice.set_secret_ka k1, k2
    
    @bob.set_secret_kb kb
  end

end

