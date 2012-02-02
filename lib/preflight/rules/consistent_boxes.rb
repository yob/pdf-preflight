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

        if round_off(@boxes[:MediaBox]) != round_off(dict[:MediaBox])
          @messages << "MediaBox must be consistent across every page (page #{page.number})"
        end

        if round_off(@boxes[:CropBox]) != round_off(dict[:CropBox])
          @messages << "CropBox must be consistent across every page (page #{page.number})"
        end

        if round_off(@boxes[:BleedBox]) != round_off(dict[:BleedBox])
          @messages << "BleedBox must be consistent across every page (page #{page.number})"
        end

        if round_off(@boxes[:TrimBox]) != round_off(dict[:TrimBox])
          @messages << "TrimBox must be consistent across every page (page #{page.number})"
        end

        if round_off(@boxes[:ArtBox]) != round_off(dict[:ArtBox])
          @messages << "ArtBox must be consistent across every page (page #{page.number})"
        end
      end

      private

      def round_off(*arr)
        arr.flatten.compact.map { |n| n.round(2) }
      end
    end
  end
end
