# coding: utf-8

module Preflight
  module Rules

    # Ensure the requested page box (MediaBox, TrimBox, etc) on every page has
    # the requested width. Dimensions can be in points, mm or inches. Skips
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
    class PageBoxWidth
      include Preflight::Measurements

      attr_reader :issues

      def initialize(box, width, units)
        @box, @units = box, units
        @orig_width = width
        @width = case units
                  when :mm then mm_to_points(width)
                  when :in then inches_to_points(width)
                  else
                    points_to_points(width)
                  end
      end

      def page=(page)
        @issues = []
        dict = page.attributes

        if dict[@box]
          box_width  = dict[@box][2] - dict[@box][0]

          if !@width.include?(box_width)
            @issues << Issue.new("#{@box} width must be #{@orig_width}#{@units}", self, :page  => page.number,
                                                                                        :box   => @box,
                                                                                        :width => @orig_width,
                                                                                        :units => @units)
          end
        end
      end

      private

      def inches_to_points(width)
        case width
        when Numeric then Range.new(in2pt(width)-1, in2pt(width)+1)
        when Range   then Range.new(in2pt(width.min), in2pt(width.max))
        else
          raise ArgumentError, "width must be a Numeric or Range object"
        end
      end

      def mm_to_points(width)
        case width
        when Numeric then Range.new(mm2pt(width)-1, mm2pt(width)+1)
        when Range   then Range.new(mm2pt(width.min), mm2pt(width.max))
        else
          raise ArgumentError, "width must be a Numeric or Range object"
        end
      end

      def points_to_points(width)
        case width
        when Numeric then Range.new(width, width)
        when Range   then width
        else
          raise ArgumentError, "width must be a Numeric or Range object"
        end
      end
    end
  end
end
