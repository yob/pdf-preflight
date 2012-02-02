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

      # each page box MUST be within .03 PDF points of the same box
      # on all other pages
      TOLERANCE = (BigDecimal.new("-0.03")..BigDecimal.new("0.03"))

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

        unless subtract_all(@boxes[:MediaBox], dict[:MediaBox]).all? { |diff| TOLERANCE.include?(diff) }
          @messages << "MediaBox must be consistent across every page (page #{page.number})"
        end

        unless subtract_all(@boxes[:CropBox], dict[:CropBox]).all? { |diff| TOLERANCE.include?(diff) }
          @messages << "CropBox must be consistent across every page (page #{page.number})"
        end

        unless subtract_all(@boxes[:BleedBox], dict[:BleedBox]).all? { |diff| TOLERANCE.include?(diff) }
          @messages << "BleedBox must be consistent across every page (page #{page.number})"
        end

        unless subtract_all(@boxes[:TrimBox], dict[:TrimBox]).all? { |diff| TOLERANCE.include?(diff) }
          @messages << "TrimBox must be consistent across every page (page #{page.number})"
        end

        unless subtract_all(@boxes[:ArtBox], dict[:ArtBox]).all? { |diff| TOLERANCE.include?(diff) }
          @messages << "ArtBox must be consistent across every page (page #{page.number})"
        end
      end

      private

      def subtract_all(one, two)
        one ||= [0, 0, 0, 0]
        two ||= [0, 0, 0, 0]

        [
          one[0] - two[0],
          one[1] - two[1],
          one[2] - two[2],
          one[3] - two[3]
        ]
      end
    end
  end
end
