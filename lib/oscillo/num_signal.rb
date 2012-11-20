module Oscillo
  # A signal that works on numeric values.
  class NumSignal < Signal
    # (see Signal#initialize)
    # Defaults to 0 instead of nil.
    def initialize(*, &block)
      @value = 0; super
    end

    # The new signal gives the running total of all values of the original
    # signal.
    #
    # @return [Signal]
    def sum
      self.inject(:+)
    end

    # The new signal gives the difference between the previous value and the
    # current value of the signal.
    #
    # @return [Signal]
    def delta
      prev = self.val
      self.class.new(self) do |v, s|
        v - prev.tap { prev = v }
      end
    end

    # The new signal gives the running product of all values of the original
    # signal.
    #
    # @return [Signal]
    def product
      self.inject(:*)
    end

    # The new signal is the sum of the original signal and the given signal.
    #
    # @param signal [Signal] the signal to sum
    # @return [Signal]
    def plus(signal)
      self.class.new(self, signal) { |a, b| a + b}
    end
    alias_method :+, :plus

    # The new signal is the difference of the original signal and the given
    # signal.
    #
    # @param signal [Signal] the signal to subtract
    # @return [Signal]
    def minus(signal)
      self.class.new(self, signal) { |a, b| a - b }
    end
    alias_method :-, :minus

    # The new signal is the product of the original signal and the given
    # signal.
    #
    # @param signal [Signal] the signal to multiply
    # @return [Signal]
    def times(signal)
      self.class.new(self, signal) { |a, b| a * b }
    end
    alias_method :*, :times

    # The new signal is the division of the original signal and the given
    # signal.
    #
    # @param signal [Signal] the signal to divide
    # @return [Signal]
    def div(signal)
      self.class.new(self, signal) { |a, b| a / b }
    end
    alias_method :/, :div

    # The new signal is the modulus of the original signal and the given
    # signal.
    #
    # @param signal [Signal] the signal to mod
    # @return [Signal]
    def mod(signal)
      self.class.new(self, signal) { |a, b| a % b }
    end
    alias_method :%, :mod

    # The new signal is the original signal raised to the power of the given
    # signal.
    #
    # @param signal [Signal] the signal to raise to the power of
    # @return [Signal]
    def pow(signal)
      self.class.new(self, signal) { |a, b| a ** b }
    end
    alias_method :**, :pow
  end
end
