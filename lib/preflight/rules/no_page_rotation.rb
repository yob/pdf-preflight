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

      attr_reader :issues

      def page=(page)
        attrs = page.attributes

        if attrs[:Rotate] && page.objects.deref(attrs[:Rotate]) != 0
          @issues = [Issue.new("Page is rotated", self, :page => page.number)]
        else
          @issues = []
        end
      end

    end
  end
end
