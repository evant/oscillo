require 'test/unit'
require 'oscillo'

class TestNumSignal < Test::Unit::TestCase
  include Oscillo

  def test_default_value
    assert_equal 0, NumSignal.new.val
  end

  def test_sum
    a = NumSignal.new(0)
    b = a.sum

    a << 1
    assert_equal 1, b.val
    a << 2
    assert_equal 3, b.val
  end

  def test_delta
    a = NumSignal.new(0)
    b = a.delta

    a << 5
    assert_equal 5, b.val
    a << 2
    assert_equal(-3, b.val)
    a << 4
    assert_equal 2, b.val
  end

  def test_product
    a = NumSignal.new(1)
    b = a.product

    a << 2
    assert_equal 2, b.val
    a << 3
    assert_equal 6, b.val
  end

  def test_plus
    a = NumSignal.new
    b = NumSignal.new
    c = a + b

    a << 1; b << 2
    assert_equal 3, c.val
  end

  def test_minus
    a = NumSignal.new
    b = NumSignal.new
    c = a - b

    a << 5; b << 2
    assert_equal 3, c.val
  end

  def test_mult
    a = NumSignal.new
    b = NumSignal.new
    c = a * b

    a << 2; b << 3
    assert_equal 6, c.val
  end

  def test_div
    a = NumSignal.new
    b = NumSignal.new(1) # Prevent division by 0
    c = a / b

    a << 6; b << 3
    assert_equal 2, c.val
  end

  def test_mod
    a = NumSignal.new
    b = NumSignal.new(1) # Prevent division by 0
    c = a % b

    a << 12; b << 5
    assert_equal 2, c.val
  end

  def test_pow
    a = NumSignal.new
    b = NumSignal.new
    c = a ** b

    a << 2; b << 3
    assert_equal 8, c.val
  end
end
