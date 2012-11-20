require 'test/unit'
require 'oscillo'

class TestSignal < Test::Unit::TestCase
  include Oscillo

  def test_initial_value
    assert_equal :test, Signal.new(:test).val
  end

  def test_change_value
    a = Signal.new
    a << :test

    assert_equal :test, a.val
  end

  def test_follows
    a = Signal.new
    b = Signal.new(a)

    a << :test
    assert_equal :test, b.val
  end

  def test_follows_initial_value
    a = Signal.new(:a)
    b = Signal.new(a)
    
    assert_equal :a, b.val
  end

  def test_follows_with_block
    a = Signal.new(0)
    b = Signal.new(a) { |x| x * 2 }

    a << 2
    assert_equal 2 * 2, b.val
  end

  def test_follows_initial_value_with_block
    a = Signal.new(2)
    b = Signal.new(a) { |x| x * 2 }

    assert_equal 2 * 2, b.val
  end

  def test_follows_multiple
    a = Signal.new
    b = Signal.new
    c = Signal.new(a, b)

    a << :test1
    b << :test2
    assert_equal [:test1, :test2], c.val
  end

  def test_follows_multiple_with_block
    a = Signal.new(0)
    b = Signal.new(0)
    c = Signal.new(a, b) { |x, y| x + y }

    a << 2
    b << 3
    assert_equal 2 + 3, c.val
  end

  def test_abort_follows
    a = Signal.new
    b = Signal.new(a) { |x| b.abort if x == :bad; x }

    a << :good
    assert_equal :good, b.val
    a << :bad
    assert_equal :good, b.val
  end

  def test_chained_follows
    a = Signal.new
    b = Signal.new(a)
    c = Signal.new(b)

    a << :test
    assert_equal :test, b.val
    assert_equal :test, c.val
  end

  def test_recursive_follows
    a = Signal.new
    b = Signal.new(a)

    # should not cause a SystemStackError
    a.follow(b)

    a << :test_a
    assert_equal :test_a, b.val
    b << :test_b
    assert_equal :test_b, a.val
  end

  def test_dont_follow
    a = Signal.new
    b = Signal.new(a)
    b.dont_follow(a)

    a << :test
    assert :test != b.val
  end
                            
  def test_on_change
    a = Signal.new(:a)
    changes = 0
    a.on_change { changes += 1 }

    assert_equal 0, changes
    a << :a1
    assert_equal 1, changes
  end

  def test_sample_on
    a = Signal.new(:start)
    b = Signal.new
    c = a.sample_on(b)

    a << :new
    assert_equal :start, c.val
    b << :changed
    assert_equal :new, c.val
  end

  def test_drop_repeats
    a = Signal.new
    b = a.drop_repeats

    changes = 0
    b.on_change { changes += 1 }

    a << :a
    assert_equal 1, changes
    a << :a
    assert_equal 1, changes
    a << :b
    assert_equal 2, changes
  end
end
