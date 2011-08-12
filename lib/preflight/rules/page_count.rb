# coding: utf-8

module Preflight
  module Rules

    # Ensure the page count matches certain criteria.
    #
    # Arguments: An integer, range, :even or :odd
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::PageCount, 1
    #     rule Preflight::Rules::PageCount, 1..2
    #     rule Preflight::Rules::PageCount, :even
    #     rule Preflight::Rules::PageCount, :odd
    #   end
    #
    class PageCount

      def initialize(pattern)
        @pattern = pattern
      end

      def check_hash(objects)
        root  = objects.deref(objects.trailer[:Root])
        pages = objects.deref(root[:Pages])
        count = objects.deref(pages[:Count])

        case @pattern
        when Fixnum then check_numeric(count)
        when Range  then check_range(count)
        when :even  then check_even(count)
        when :odd   then check_odd(count)
        else
          ["PageCount: invalid pattern (#{@pattern})"]
        end
      end

      private

      def check_numeric(count)
        if count != @pattern
          ["Page count must equal #{@pattern}"]
        else
          []
        end
      end

      def check_range(count)
        if !@pattern.include?(count)
          ["Page count must be between #{@pattern.min} and #{@pattern.max}"]
        else
          []
        end
      end

      def check_even(count)
        if count.odd?
          ["Page count must be an even number"]
        else
          []
        end
      end

      def check_odd(count)
        if count.even?
          ["Page count must be an odd number"]
        else
          []
        end
      end
    end
  end
end
