# coding: utf-8

module Preflight
  module Rules

    # Every page should have a CropBox that matches the MediaBox
    #
    # Arguments: none
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::CropboxMatchesMediabox
    #   end
    #
    class CropboxMatchesMediabox

      attr_reader :messages

      def page=(page)
        @messages = []
        dict = page.attributes

        if dict[:CropBox] && round_off(dict[:CropBox]) != round_off(dict[:MediaBox])
          @messages << "CropBox must match MediaBox (page #{page.number})"
        end
      end

      private

      def round_off(*arr)
        arr.flatten.map { |n| n.round(2) }
      end
    end
  end
end
