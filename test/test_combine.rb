require 'test/unit'
require 'oscillo'

class TestCombine < Test::Unit::TestCase
  include Oscillo

  def test_either
    a = Signal.new
    b = Signal.new
    c = Combine::either(a, b)

    a << :a
    assert_equal :a, c.val
    b << :b
    assert_equal :b, c.val
  end

  def test_when
    a = Signal.new
    b = Signal.new
    c = Combine::when(a, b) { |x| x != :bad }

    a << :a
    assert_equal :a, c.val
    a << :bad
    assert_equal :a, c.val
    b << :b
    assert_equal :b, c.val
    b << :bad
    assert_equal :b, c.val
  end

  def test_when_not
    a = Signal.new
    b = Signal.new
    c = Combine::when_not(a, b) { |x| x == :bad }

    a << :a
    assert_equal :a, c.val
    a << :bad
    assert_equal :a, c.val
    b << :b
    assert_equal :b, c.val
    b << :bad
    assert_equal :b, c.val
  end
end
