# coding: utf-8

module Preflight
  module Rules

    # Specify the presence of page boxes
    #
    # Arguments: hash containing :any or :all key with an array value of box
    # names as symbols
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::BoxPresence, :any => [:MediaBox, :CropBox]
    #     rule Preflight::Rules::BoxPresence, :all => [:MediaBox, :CropBox]
    #   end
    #
    class BoxPresence

      attr_reader :issues

      def initialize(options)
        if options[:any].nil? && options[:all].nil?
          raise "Preflight::Rules::BoxPresence requires :any or :all option"
        elsif options[:any] && options[:all]
          raise "Preflight::Rules::BoxPresence requires only one of :any or :all option"
        end

        @options = options
      end

      def page=(page)
        dict = page.attributes

        present_boxes = dict.keys & [:MediaBox, :CropBox, :TrimBox, :ArtBox]

        if @options[:any] && !@options[:any].any? { |b| present_boxes.include?(b) }
          @issues = [Issue.new("page must have any of #{@options[:any].join(", ")}", self, :page => page.number)]
        elsif @options[:all] && !@options[:all].all? { |b| present_boxes.include?(b) }
          @issues = [Issue.new("page must have all of #{@options[:all].join(", ")}", self, :page => page.number)]
        else
          @issues = []
        end
      end
    end
  end
end

