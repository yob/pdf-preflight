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

      attr_reader :issues

      def page=(page)
        media  = page.attributes[:MediaBox]
        bleed  = page.attributes[:BleedBox]
        trim   = page.attributes[:TrimBox]
        art    = page.attributes[:ArtBox]

        if media && bleed && (bleed[2] > media[2] || bleed[3] > media[3])
          @issues = [Issue.new("BleedBox must be smaller than MediaBox", self, :page      => page.number,
                                                                               :large_box => "BleedBox",
                                                                               :small_box => "MediaBox")]
        elsif trim && bleed && (trim[2] > bleed[2] || trim[3] > bleed[3])
          @issues = [Issue.new("TrimBox must be smaller than BleedBox", self, :page      => page.number,
                                                                              :large_box => "TrimBox",
                                                                              :small_box => "BleedBox")]
        elsif art && bleed && (art[2] > bleed[2] || art[3] > bleed[3])
          @issues = [Issue.new("ArtBox must be smaller than BleedBox", self, :page       => page.number,
                                                                             :large_box => "ArtBox",
                                                                             :small_box => "BleedBox")]
        elsif trim && media && (trim[2] > media[2] || trim[3] > media[3])
          @issues = [Issue.new("TrimBox must be smaller than MediaBox", self, :page      => page.number,
                                                                              :large_box => "TrimBox",
                                                                              :small_box => "MediaBox")]
        elsif art && media && (art[2] > media[2] || art[3] > media[3])
          @issues = [Issue.new("ArtBox must be smaller than MediaBox", self, :page      => page.number,
                                                                             :large_box => "ArtBox",
                                                                             :small_box => "MediaBox")]
        else
          @issues = []
        end
      end
    end
  end
end
