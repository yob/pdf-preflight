# coding: utf-8

module Preflight
  module Rules

    # Ensure the requested page box (MediaBox, TrimBox, etc) on every page has
    # the requested height. Dimensions can be in points, mm or inches. Skips
    # the page if the requested box isn't defined, it's up to other rules to
    # check for the existence of the box.
    #
    # Arguments: the target page box, the target height and the the units
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::PageBoxHeight, :MediaBox, 100, :mm
    #     rule Preflight::Rules::PageBoxHeight, :TrimBox, 600, :pts
    #     rule Preflight::Rules::PageBoxHeight, :CropBox, 5, :in
    #     rule Preflight::Rules::PageBoxHeight, :MediaBox, 100..101, :mm
    #     rule Preflight::Rules::PageBoxHeight, :TrimBox, 600..700, :pts
    #     rule Preflight::Rules::PageBoxHeight, :CropBox, 5..6, :in
    #   end
    #
    class PageBoxHeight
      include Preflight::Measurements

      attr_reader :issues

      def initialize(box, height, units)
        @box, @units = box, units
        @orig_height = height
        @height = case units
                  when :mm then mm_to_points(height)
                  when :in then inches_to_points(height)
                  else
                    points_to_points(height)
                  end
      end

      def page=(page)
        @issues = []
        dict = page.attributes

        if dict[@box]
          box_height  = dict[@box][3] - dict[@box][1]

          if !@height.include?(box_height)
            @issues << Issue.new("#{@box} height must be #{@orig_height}#{@units}", self, :page   => page.number,
                                                                                          :box    => @box,
                                                                                          :height => @orig_height,
                                                                                          :units  => @units)
          end
        end
      end

      private

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
