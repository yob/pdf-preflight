# coding: utf-8

module Preflight
  module Rules

    # Ensure that the requests page box (MediaBox, TrimBox, etc) on every page
    # has the requested size. Dimensions can be in points, mm or inches. Skips
    # the page if the requested box isn't defined, it's up to other rules to
    # check for the existence of the box. Pass an array of sizes to allow each
    # of those sizes.
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::PageBoxSize, :MediaBox, [
    #       { :width => 100, :height => 200, :units => :mm },
    #       { :width => 200, :height => 400, :units => :mm }
    #     ]
    #     rule Preflight::Rules::PageBoxSize, :TrimBox,
    #       { :width => 600, :height => 200, :units => :pts }
    #   end
    #
    class PageBoxSize
      include Preflight::Measurements

      attr_reader :issues

      def initialize(box, sizes)
        @box, @units = box
        sizes = [sizes] if sizes.kind_of?(Hash)
        @orig_sizes = sizes

        @sizes = sizes.map do |size|
          size[:width]  = length_to_points(size[:width], size[:units])
          size[:height] = length_to_points(size[:height], size[:units])
          size
        end
      end

      def page=(page)
        @issues = []
        dict = page.attributes

        if dict[@box]
          box_width = dict[@box][2] - dict[@box][0]
          box_height = dict[@box][3] - dict[@box][1]

          invalid_size = @sizes.none? do |size|
            size[:width].include?(box_width) &&
            size[:height].include?(box_height)
          end

          if invalid_size
            @issues << Issue.new("#{@box} size didn't match provided size",
              self,
              :page => page.number,
              :box => @box,
              :box_height => box_height,
              :box_width => box_width)
          end
        end
      end

      private

      def length_to_points(length, units)
        case units
        when :mm then mm_to_points(length)
        when :in then inches_to_points(length)
        else
          points_to_points(length)
        end
      end

      def inches_to_points(height)
        case height
        when Numeric then Range.new(in2pt(height)-1, in2pt(height)+1)
        when Range   then Range.new(in2pt(height.min), in2pt(height.max))
        else
          raise ArgumentError, "height must be a Numeric or Range object"
        end
      end

      def mm_to_points(height)
        case height
        when Numeric then Range.new(mm2pt(height)-1, mm2pt(height)+1)
        when Range   then Range.new(mm2pt(height.min), mm2pt(height.max))
        else
          raise ArgumentError, "height must be a Numeric or Range object"
        end
      end

      def points_to_points(height)
        case height
        when Numeric then Range.new(height, height)
        when Range   then height
        else
          raise ArgumentError, "height must be a Numeric or Range object"
        end
      end

    end
  end
end