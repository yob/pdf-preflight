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
          [Issue.new("PageCount: invalid pattern", self)]
        end
      end

      private

      def check_numeric(count)
        if count != @pattern
          [Issue.new("Page count must equal #{@pattern}", self, :pattern => :invalid, :count => count)]
        else
          []
        end
      end

      def check_range(count)
        if !@pattern.include?(count)
          [Issue.new("Page count must be between #{@pattern.min} and #{@pattern.max}", self, :pattern => @pattern, :count => count)]
        else
          []
        end
      end

      def check_even(count)
        if count.odd?
          [Issue.new("Page count must be an even number", self, :pattern => @pattern, :count => count)]
        else
          []
        end
      end

      def check_odd(count)
        if count.even?
          [Issue.new("Page count must be an odd number", self, :pattern => @pattern, :count => count)]
        else
          []
        end
      end
    end
  end
end
