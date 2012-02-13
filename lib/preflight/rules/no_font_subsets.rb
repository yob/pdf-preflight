# coding: utf-8

module Preflight
  module Rules

    # check a file has no font subsets. Subsets are handy and valid in
    # standards like PDFX/1a, but they can make it hard to edit a file
    #
    # Arguments: none
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::NoFontSubsets
    #   end
    #
    class NoFontSubsets

      def check_hash(ohash)
        array = []
        ohash.each do |key, obj|
          next unless obj.is_a?(::Hash) && obj[:Type] == :Font
          if subset?(obj)
            array << Issue.new("Font partially subseted (#{obj[:BaseFont]})", self, :base_font => obj[:BaseFont])
          end
        end
        array
      end

      private

      def subset?(font)
        font[:BaseFont] && font[:BaseFont].to_s[/.+\+.+/]
      end
    end
  end
end
