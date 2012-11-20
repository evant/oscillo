module Oscillo
  # A signal that operates on boolean values.
  class BoolSignal < Signal
    # (see Signal#initialize)
    # Defaults to false instead of nil.
    def initialize(*, &block)
      @value = false; super
    end

    # Negates the signal. i.e if the original signal was true, the new signal is
    # false and vice versa.
    #
    # @return [Signal]
    def not
      self.class.new(self) { |v| !v }
    end
    alias_method '!', :not

    # The new signal is true if all of the given signals are true, otherwise it
    # is false.
    #
    # @param signals [[Signal]]
    # @return [Signal]
    def and(*signals)
      self.class.new(self, *signals) { |*vs, s| vs.all? }
    end
    alias_method :&, :and

    # The new signal is true if all of the given signals are false, otherwise it
    # is true.
    #
    # @param signals [[Signal]]
    # @return [Signal]
    def nand(*signals)
      self.and(*signals).not
    end

    # The new signal is true if any of the given signals are true, otherwise it
    # is false.
    #
    # @param signals [[Signal]]
    # @return [Signal]
    def or(*signals)
      self.class.new(self, *signals) { |*vs, s| vs.any? }
    end
    alias_method :|, :or

    # The new signal is true if any of the given signals are false, otherwise it
    # is false.
    #
    # @param signals [[Signal]]
    # @return [Signal]
    def nor(*signals)
      self.or(*signals).not
    end

    # The new signal is true if only one of the given signals are true,
    # otherwise it is false.
    #
    # @param signal [Signal]
    # @return [Signal]
    def xor(signal)
      self.class.new(self, signal) { |a, b| a ^ b }
    end
    alias_method :^, :xor

    # The new signal is true if only one of the given signals are false,
    # otherwise it is false.
    #
    # @param signal [Signal]
    # @return [Signal]
    def xnor(signal)
      self.xor(signal).not
    end
  end
end
