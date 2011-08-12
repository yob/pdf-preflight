# coding: utf-8

module Preflight
  module Rules

    # For each page MediaBox must be the biggest box, followed by the
    # BleedBox or ArtBox, followed by the TrimBox.
    #
    # Boxes may be omitted, but if they're provided they must be correctly nested.
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
    class BoxNesting

      attr_reader :messages

      def page=(page)
        media  = page.page_object[:MediaBox]
        bleed  = page.page_object[:BleedBox]
        trim   = page.page_object[:TrimBox]
        art    = page.page_object[:ArtBox]

        if media && bleed && (bleed[2] > media[2] || bleed[3] > media[3])
          @messages = ["BleedBox must be smaller than MediaBox (page #{page.number})"]
        elsif trim && bleed && (trim[2] > bleed[2] || trim[3] > bleed[3])
          @messages = ["TrimBox must be smaller than BleedBox (page #{page.number})"]
        elsif art && bleed && (art[2] > bleed[2] || art[3] > bleed[3])
          @messages = ["ArtBox must be smaller than BleedBox (page #{page.number})"]
        elsif trim && media && (trim[2] > media[2] || trim[3] > media[3])
          @messages = ["TrimBox must be smaller than MediaBox (page #{page.number})"]
        elsif art && media && (art[2] > media[2] || art[3] > media[3])
          @messages = ["ArtBox must be smaller than MediaBox (page #{page.number})"]
        else
          @messages = []
        end
      end
    end
  end
end
