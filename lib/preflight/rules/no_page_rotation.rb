# coding: utf-8

module Preflight
  module Rules

    # Ensure the target file contains no page rotation.
    #
    # Rotating pages is generally acceptable in most specs but it can cause
    # rendering issues with poor waulity PDF consumers.
    #
    # Arguments: none
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::NoPageRotation
    #   end
    #
    class NoPageRotation

      attr_reader :messages

      def page=(page)
        attrs = page.attributes

        if attrs[:Rotate] && attrs[:Rotate] != 0
          @messages = ["Page is rotated (page #{page.number})"]
        else
          @messages = []
        end
      end
    end
  end
end
