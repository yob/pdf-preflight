# coding: utf-8

module Preflight
  module Rules

    # For PDFX/1a, every page must have MediaBox, plus either ArtBox or
    # TrimBox
    #
    # Arguments: none
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::PrintBoxes
    #   end
    #
    class PrintBoxes

      attr_reader :issues

      def page=(page)
        dict = page.attributes

        if dict[:MediaBox].nil?
          @issues = [Issue.new("every page must have a MediaBox", self, :page => page.number)]
        elsif dict[:ArtBox].nil? && dict[:TrimBox].nil?
          @issues = [Issue.new("every page must have either an ArtBox or a TrimBox", self, :page => page.number)]
        elsif dict[:ArtBox] && dict[:TrimBox]
          @issues = [Issue.new("no page can have both ArtBox and TrimBox - TrimBox is preferred", self, :page => page.number)]
        else
          @issues = []
        end
      end
    end
  end
end
