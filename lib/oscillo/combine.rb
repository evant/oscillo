module Oscillo
  # Constructs new signals by combining multiple signals together in different
  # ways.
  module Combine
    # When any of the signals change, update the new signal with the value of
    # the last changed signal.
    #
    # @param signals [[Signal]] the signals to update on
    # @return [Signal]
    def self.either(*signals)
      Signal.new(*signals) do |*vs, s|
        s.source.val
      end
    end

    # Updates the signal when any of the given signals change and the block
    # evaluates to true. The value is the value of the last changed signal.
    # @see when_not
    #
    # @param signals [[Signal]] the signals to update on
    # @yield [value] the new value of the last changed signal
    # @return [Signal]
    def self.when(*signals, &block)
      Signal.new(*signals) do |*vs, s|
        s.abort unless block.(s.source.val)
        s.source.val
      end
    end

    # Updates the signal when any of the given signals change and the block
    # evaluates to false. The value is the value of the last changed signal.
    # @see when
    #
    # @param signals [[Signal]] the signals to update on
    # @yield [value] the new value of the last changed signal
    # @return [Signal]
    def self.when_not(*signals, &block)
      Signal.new(*signals) do |*vs, s|
        s.abort if block.(s.source.val)
        s.source.val
      end
    end
  end
end
