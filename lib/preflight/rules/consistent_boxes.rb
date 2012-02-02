# coding: utf-8

module Preflight
  module Rules

    # Every page should have identical page boxes
    #
    # Arguments: none
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::BoxNesting
    #   end
    #
    class ConsistentBoxes

      TOLERANCE = (BigDecimal.new("-0.02")..BigDecimal.new("0.02"))

      attr_reader :messages

      def initialize
        @boxes = {}
      end

      def page=(page)
        @messages = []
        dict = page.attributes

        @boxes[:MediaBox] ||= dict[:MediaBox]
        @boxes[:CropBox]  ||= dict[:CropBox]
        @boxes[:BleedBox] ||= dict[:BleedBox]
        @boxes[:TrimBox]  ||= dict[:TrimBox]
        @boxes[:ArtBox]   ||= dict[:ArtBox]

        unless check_boxes(@boxes[:MediaBox], dict[:MediaBox])
          @messages << "MediaBox must be consistent across every page (page #{page.number})"
        end

        unless check_boxes(@boxes[:CropBox], dict[:CropBox])
          @messages << "CropBox must be consistent across every page (page #{page.number})"
        end
        unless check_boxes(@boxes[:BleedBox], dict[:BleedBox])
          @messages << "BleedBox must be consistent across every page (page #{page.number})"
        end

        unless check_boxes(@boxes[:TrimBox], dict[:TrimBox])
          @messages << "TrimBox must be consistent across every page (page #{page.number})"
        end

        unless check_boxes(@boxes[:ArtBox], dict[:ArtBox])
          @messages << "ArtBox must be consistent across every page (page #{page.number})"
        end
      end

      private

      def check_boxes(first, second)
        TOLERANCE.include?(width(first) - width(second)) &&
          TOLERANCE.include?(height(first) - height(second))
      end

      def width(box)
        return 0 if box.nil?

        box[2] - box[0]
      end

      def height(box)
        return 0 if box.nil?

        box[3] - box[1]
      end

      def round_off(*arr)
        arr.flatten.compact.map { |n| n.round(2) }
      end
    end
  end
end
