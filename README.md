# Oscillo

Based off of functional reactive programming, oscillo gives you a signal that
represents a value changing over time. You can manipulate signals and combine
them together in various ways.

## Installation

Add this line to your application's Gemfile:

    gem 'oscillo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install oscillo

## Usage

### Creating and using signals

Creating a signal is as simple as

    s = Oscillo::Signal.new

You modify the value of the signal with `s << :value` and you get the current
value of the signal with `s.value`, or `s.val` if you want to save a couple of
letters.

If you want to give a signal a starting value, you just pass it to the
constructor.

    s = Oscillo::Signal.new(0)

### Following other signals

If you pass another signal as an argument to `new`, the signal's value will
follow the other one.

    a = Oscillo::Signal.new
    b = Oscillo::Signal.new(a)

    a << :value
    b.val #=> :value

You can pass a block to `new` to modify how the new signal follows the old.

    a = Oscillo::Signal.new(0)
    b = Oscillo::Signal.new(a) { |v| v * 2 }

    a << 3
    b.val #=> 6

You can also follow multiple signals at once. The new signal will change if any
of the signal that you follow changes.

    a = Oscillo::Signal.new(0)
    b = Oscillo::Signal.new(0)
    c = Oscillo::Signal.new(a, b) { |v1, v2| v1 + v2 }

    a << 2
    c.val #=> 2
    b << 3
    c.val #=> 5

### Useful methods in the block

The last argument given to the block passed to new is the signal itself. This is
so you utilize other methods to query the signal and modify it's changed value.

{Oscillo::Signal#abort} aborts the new value change, keeping the old one.

    a = Oscillo::Signal.new
    b = Oscillo::Signal.new(a) { |v, s| s.abort if v == :bad; v }

    a << :good
    b.val #=> :good
    a << :bad
    b.val #=> :bad

{Oscillo::Signal#source} gives the original signal that caused the cascade of
changes. This is useful if you are following multiple signals and want to know
which one actually changed.

    a = Oscillo::Signal.new
    b = Oscillo::Signal.new
    c = Oscillo::Signal.new(a, b) do |v1, v2, s|
      "The last change was to #{s.source.val}"
    end

    a << 1
    c.val #=> "The last change was to 1"
    b << 2
    c.val #=> "The last change was to 2"

### Combining signals

You can combine signals together in different ways. For example,
{Oscillo::Combine.either} updates the new signal to the value of whichever was
the last signal to change.

    a = Oscillo::Signal.new
    b = Oscillo::Signal.new
    c = Oscillo::Combine.either(a, b)
    a << "a changed"
    c.val #=> "a changed"
    b << "b changed"
    c.val #=> "b changed"

See {Oscillo::Combine} for all combination methods.

### Enumerable

A signal can thought of a sequence of values over time. Therefore, {Oscillo::Signal}
implements a large number of Enumerable's methods. For example,

    a = Oscillo::Signal.new(0)
    b = a.map { |v| v ** 2 }
    a << 3
    b.val #=> 9

See {Oscillo::Enumerable} for all the methods implemented.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
