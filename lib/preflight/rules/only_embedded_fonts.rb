# coding: utf-8

module Preflight
  module Rules

    # Check the target PDF only uses embedded fonts
    #
    # Arguments: none
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::OnlyEmbeddedFonts
    #   end
    #
    class OnlyEmbeddedFonts

      attr_reader :issues

      def page=(page)
        @issues = []

        page.fonts.each { |key, obj|
          obj = page.objects.deref(obj)
          if !embedded?(page.objects, obj)
            @issues << Issue.new("Font not embedded", self, :base_font => obj[:BaseFont])
          end
        }
      end

      private

      def embedded?(objects, font)
        return true if font[:Subtype] == :Type3

        if font.has_key?(:FontDescriptor)
          descriptor = objects.deref(font[:FontDescriptor])
          descriptor.has_key?(:FontFile) || descriptor.has_key?(:FontFile2) || descriptor.has_key?(:FontFile3)
        elsif font[:Subtype] == :Type0
          descendants = objects.deref(font[:DescendantFonts])
          descendants.all? { |f|
            f = objects.deref(f)
            embedded?(objects, f)
          }
        else
          false
        end
      end

    end
  end
end
