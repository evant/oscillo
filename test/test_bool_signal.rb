require 'test/unit'
require 'oscillo'

class TestBoolSignal < Test::Unit::TestCase
  include Oscillo

  def self.test_bool(method, expected)
    a = BoolSignal.new
    b = BoolSignal.new
    c = a.send(method, b)

    define_method("test_#{method}") do
      i = 0
      [true, false].each do |a_val|
        [true, false].each do |b_val|
          a << a_val; b << b_val
          assert_equal expected[i], c.val
          i += 1
        end
      end
    end
  end

  def test_default_value
    assert_equal false, BoolSignal.new.val
  end
  
  def test_not
    a = BoolSignal.new
    b = a.not

    a << true
    assert_equal false, b.val
    a << false
    assert_equal true, b.val
  end

  test_bool :and,  [true,  false, false, false]
  test_bool :nand, [false, true,  true,  true ]
  test_bool :or,   [true,  true,  true,  false]
  test_bool :nor,  [false, false, false, true ]
  test_bool :xor,  [false, true,  true,  false]
  test_bool :xnor, [true,  false, false, true ]
end
