module Oscillo
  # Adds enumerable-like methods to Signal.
  module Enumerable
    NO_ARG = Object.new
    private_constant :NO_ARG

    # Returns a signal that is the result of running the values of the original
    # signal through the block.
    #
    # @yield [*signals] gives the new values of the signals to the block
    # @return [Signal]
    def collect(&block)
      self.class.new(self) { |*v, s| block.(*v) }
    end
    alias_method :map, :collect

    # Returns a signal that changes only when the original signal changes and
    # the block is not false.
    # @see #reject
    #
    # @yield [value] gives the new value of the signal to the block
    # @return [Signal]
    def find_all(&block)
      self.class.new(self) do |v, s|
        s.abort unless block.(v); v
      end
    end
    alias_method :select, :find_all

    # Returns a signal that changes only when the original signal changes and
    # the block is false.
    # @see #find_all
    #
    # @yield [value] give the new value of the signal to the block
    # @return [Signal]
    def reject(&block)
      self.class.new(self) do |v, s|
        s.abort if block.(v); v
      end
    end

    # Passes each value of the signal to the given block. The value of the
    # resulting signal is true if the block never returns false or nil. If the
    # block is not given, uses an implicit block of {|value| value} (that is
    # {#all?} will return true only if none of the signal values were false or
    # nil.)
    # @note Only takes in to consideration values from the time the signal was
    #   created.
    # @see #any?
    #
    # @yield [new_value] give the new value of the signal to the block
    # @return [Signal<Boolean>]
    def all?(&block)
      self.class.new(true, self) do |v, s|
        v = block.(v) if block_given?
        s.val & v
      end
    end

    # Passes each value of the signal to the given block. The value of the
    # resulting signal is true if the block ever returns a value other than
    # false or nil. If the block is not given, uses an implicit block of
    # {|value| value} (that is {#any?} will return true if at least one of the
    # signal values were not false or nil.)
    # @note Only takes in to consideration values from the time the signal was
    #   created.
    # @see #all?
    #
    # @yield [new_value] give the new value of the signal to the block
    # @return [Signal<Boolean>]
    def any?(&block)
      self.class.new(false, self) do |v, s|
        s.val | block.(v)
      end
    end

    # Take the value from this signal and merges it with the values of the given
    # signals to form an array.
    #
    # @param signals [[Signal]] the other signals to merge in the array
    # @return [Signal]
    def zip(*signals)
      self.class.new(self, *signals) {|*v, s| v }
    end

    # Equivalent to {Signal#on_change}
    #
    # @yield (see Signal#on_change)
    # @return [Signal]
    def each(&block)
      self.on_change(&block)
    end

    # Returns the number values that the signal has had. If an argument is
    # given, counts the number of values in the signal, for which equals to
    # item. If a block is given, counts the number of values yielding a true
    # value.
    # @note Only takes in to consideration values from the time the signal was
    #   created.
    #
    # @overload count
    #   @return number of values that the signal had
    # @overload count(obj)
    #   @param obj values to count
    #   @return number of values equal to obj that the signal had
    # @overload count
    #   @yield [value] gives the new value to the block
    #   @return number of values for which the block evaluates to true
    def count(obj=NO_ARG, &block)
      return count_with_arg(obj) unless obj.equal?(NO_ARG)
      return count_with_block(&block) if block_given?

      self.class.new(0, self) do |v, s|
        s.val + 1
      end
    end

    # Combines all values of the signal by applying a binary operation,
    # specified by a block or a symbol that names a method or operator. If you
    # specify a block, then for each value in this signal the block is passed an
    # accumulator value (memo) the new value. If you specify a symbol instead,
    # then each new value will be passed to the named method of memo. In either
    # case, the result becomes the new value for memo.
    #
    # @overload inject
    #   @yield [memo, value] gives the memo and the new value of the signal to the
    #     block
    # @overload inject(symbol)
    #   @param symbol that represents method to call on memo
    # @overload inject(initial)
    #   @param initial the start value of the memo
    #   @yield [memo, value] gives the memo and the new value of the signal to the
    #     block
    # @overload inject(initial, symbol)
    #   @param initial the start value of the memo
    #   @param symbol that represents method to call on memo
    # @return [Signal]
    def inject(*args, &block)
      if block_given?
        inject_with_block(*args, &block)
      else
        inject_with_sym(*args)
      end
    end
    alias_method :reduce, :inject

    private

    def count_with_arg(obj)
      self.class.new(0, self) do |v, s|
        obj == v ? s.val + 1 : s.val
      end
    end

    def count_with_block(&block)
      self.class.new(0, self) do |v, s|
        block.(v) ? s.val + 1 : s.val
      end
    end

    def inject_with_sym(initial=NO_ARG, sym)
      first_run = true
      self.class.new(initial, self) do |v, s|
        if first_run and initial.equal?(NO_ARG)
          first_run = false; v
        else
          s.val.send(sym, v)
        end
      end
    end

    def inject_with_block(initial=NO_ARG, &block)
      first_run = true
      self.class.new(initial, self) do |v, s|
        if first_run and initial.equal?(NO_ARG)
          first_run = false; v
        else
          block.(s.val, v)
        end
      end
    end
  end
end
