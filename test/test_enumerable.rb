require 'test/unit'
require 'oscillo'

class TestEnumerable < Test::Unit::TestCase
  include Oscillo

  def test_collect
    a = Signal.new(0)
    b = a.map { |x| x * 2 }

    a << 2
    assert_equal 2 * 2, b.val
  end

  def test_find_all
    a = Signal.new
    b = a.find_all { |x| x == :good }

    a << :good
    assert_equal :good, b.val
    a << :bad
    assert_equal :good, b.val
  end

  def test_select
    test_find_all
  end

  def test_reject
    a = Signal.new
    b = a.reject { |x| x == :bad }

    a << :good
    assert_equal :good, b.val
    b << :bad
    assert_equal :bad, b.val
  end

  def test_all?
    a = Signal.new(:good)
    b = a.all? { |x| x == :good }

    assert b.val
    a << :bad
    assert !b.val
    a << :good
    assert !b.val
  end

  def test_any?
    a = Signal.new
    b = a.any? { |x| x == :good }

    a << :bad
    assert !b.val
    a << :good
    assert b.val
    a << :bad
    assert b.val 
  end

  def test_zip
    a = Signal.new
    b = Signal.new
    c = a.zip(b)

    a << :a
    b << :b
    assert_equal [:a, :b], c.val
  end

  def test_inject_with_block
    a = Signal.new("a")
    b = a.inject { |str, value| str + value }

    assert_equal "a", b.val
    a << "b"
    assert_equal "ab", b.val
  end

  def test_inject_with_symbol
    a = Signal.new(0)
    b = a.inject(:+)

    a << 1
    assert_equal 1, b.val
    a << 2
    assert_equal 3, b.val
  end

  def test_inject_with_initial_and_block
    a = Signal.new(:a)
    b = a.inject([]) { |array, value| array << value }

    assert_equal [:a], b.val
    a << :b
    assert_equal [:a, :b], b.val
  end

  def test_inject_with_initial_and_symbol
    a = Signal.new(1)
    b = a.inject(0, :+)

    assert_equal 1, b.val
    a << 2
    assert_equal 3, b.val
  end

  def test_count
    a = Signal.new(:a)
    b = a.count

    assert_equal 1, b.val
    a << :b
    assert_equal 2, b.val
  end

  def test_count_with_arg
    a = Signal.new
    b = a.count(:good)

    a << :good
    assert_equal 1, b.val
    a << :bad
    assert_equal 1, b.val
  end

  def test_count_with_block
    a = Signal.new
    b = a.count { |x| x == :good }

    a << :good
    assert_equal 1, b.val
    a << :bad
    assert_equal 1, b.val
  end
end
