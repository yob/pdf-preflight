# coding: utf-8

module Preflight
  module Rules

    # Ensure the target file contains no private application data.
    #
    # PDF generating apps (like Adobe Illustrator) can embed their own private
    # data in saved PDFs. This data is generally harmless and ignored by all
    # other PDF consumers, but it can lead to large increases in file size.
    #
    # Arguments: none
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::NoPrivateData
    #   end
    #
    class NoPrivateData

      attr_reader :messages

      def page=(page)
        attrs = page.attributes

        if attrs[:PieceInfo]
          @messages = ["Page contains private PieceInfo data (page #{page.number})"]
        else
          @messages = []
        end
      end
    end
  end
end
