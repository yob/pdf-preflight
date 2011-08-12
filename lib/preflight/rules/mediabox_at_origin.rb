# coding: utf-8

module Preflight
  module Rules

    # Checks the MediaBox for every page is at 0,0. This isn't required by
    # any standards but is good practice to ensure correct rendering with
    # some applications.
    #
    # Arguments: none
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::MediaboxAtOrigin
    #   end
    #
    class MediaboxAtOrigin

      attr_reader :messages

      def page=(page)
        @messages = []
        dict = page.attributes

        if round_off(dict[:MediaBox][0,2]) != [0,0]
          @messages << "MediaBox must begin at 0,0 (page #{page.number})"
        end
      end

      private

      def round_off(*arr)
        arr.flatten.compact.map { |n| n.round(2) }
      end
    end
  end
end
