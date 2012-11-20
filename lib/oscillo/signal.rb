require 'oscillo/enumerable'

module Oscillo
  # A signal that changes over time. This change can either be explicit through
  # the use of {#change} or {#<<}, or it can be implicit when any of the signals
  # that this signal follows changes.
  #
  # @author Evan Tatarka <evan@tatarka.me>
  class Signal
    include Enumerable

    # Creates a new Signal with an optional initial value, signals to follow,
    # and block. The block converts the values from any signals that this one
    # follows to the value of this signal. If no block is given, the value will
    # be an array of all the values of the signals that it follows (or if it is
    # just following one signal, the value of that signal).
    #
    # @overload initialize(*signals)
    #   Follows some number of other signals, changing when they change.
    #   @param signals [Signal] the signals to follow
    #   @yield [*signals, self] gives the new values of the signals to the block
    #
    # @overload initialize(start_value, *signals)
    #   Starts with an initial value and follows other signals when they change.
    #   @param start_value the initial value of this signal
    #   @param signals [Signal] the signals to follow
    #   @yield [*signals, self] gives the new values of the signals to the block
    def initialize(*values, &block)
      @on_change = []
      @follows = []
      @followed_by = []

      @block = block || ->(*x, s) { x.size <= 1 ? x.first : x }

      return if values.empty?

      # first may be initial value instead of signal
      first, *rest = *values
      if first.is_a?(self.class)
        follow(*values)
      else
        @value = first
        follow(*rest)
      end
    end
 
    # Follows additional signals, changing when those signals change. This is
    # necessary to define mutually recursive signals.
    # @note Immediately updates value.
    #
    # @param signals [Signal] the signals to follow
    # @return [self]
    def follow(*signals)
      @follows += signals.each { |signal| signal.followed_by(self) }
      update(self)

      self
    end

    # Stops following the given signals.
    # @note Immediately updates value.
    #
    # @param signals [Signal] the signals to stop following
    # @return [self]
    def dont_follow(*signals)
      @follows -= signals.each { |signal| signal.not_followed_by(self) } 
      update(self)

      self
    end

    # Updates the value if this signal to represent the values of the signals
    # that it follows. This is called automatically when dependent signals
    # change so you don't need to call this manually in most cases.
    #
    # @param source [Signal] The signal that initialized the update. If not
    #   passed, then this signal will be the source of the update.
    def update(source=nil)
      return if @follows.empty? # nothing to update

      @source = source
      @aborted = false
      new_value = @block.(*@follows.map(&:value), self)
      self.change(new_value) unless @aborted
    end

    # Returns the current value of the signal
    # 
    # @return the current value
    def value
      @value
    end
    alias_method :val, :value

    # Change the current value of the signal. This will update all signals that
    # follow this on as well as call all {#on_change} callbacks registered.
    #
    # @param new_value the new value of the signal
    # @return [self]
    def change(new_value)
      @value = new_value
      @on_change.each { |c| c.(new_value) }

      unless self === source
        @followed_by.each { |f| f.update(source || self) }
      end
      @source = nil

      self
    end
    alias_method :<<, :change

    # Register a callback that will be called any time the signal value is
    # changed.
    #
    # @yield [value] gives the new value to the block
    # @return [self]
    def on_change(&block)
      @on_change << block

      self
    end

    # Aborts the change so that the value stays the same, no callbacks
    # registered by {#on_change} are called, and no dependent signals are
    # changed. 
    # @note This should only be called in the block passed to {#initialize}.
    def abort
      @aborted = true
    end

    # The original source of the current run of signal changes. This can be
    # useful to know which signal caused the change if you are following
    # multiple signals.
    # @note This is only defined within the block passed to {#initialize}.
    #
    # @return [Signal] the signal that caused the change
    def source
      @source
    end

    # The value of the signal as a string, for convenience.
    #
    # @return [String] the signal value
    def to_s
      value.to_s
    end

    # The value of the signal as an integer, for convenience.
    #
    # @return [Fixnum] the signal value
    def to_i
      value.to_i
    end

    # The new signal ignores change events when the new value is the same as the
    # old value.
    #
    # @return [Signal]
    def drop_repeats
      self.class.new(self) do |v, s|
        s.abort if s.val == v; v
      end
    end

    # Updates the new signal to the value of this signal any time the value of
    # sample changes.
    #
    # @param sample [Signal] the signal to update on
    # @return [Signal]
    def sample_on(sample)
      Signal.new(self.val, sample) do |v, s|
        self.val
      end
    end

    protected

    def followed_by(follower)
      @followed_by << follower
    end

    def not_followed_by(follower)
      @followed_by.delete(follower)
    end
  end
end
