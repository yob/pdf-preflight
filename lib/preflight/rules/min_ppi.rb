# coding: utf-8

require 'yaml'
require 'matrix'

module Preflight
  module Rules

    # For high quality prints, you generally want raster images to be
    # AT LEAST 300 points-per-inch (ppi). 600 is better, 1200 better again.
    #
    # Arguments: the lowest PPI that is ok
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::MinPpi, 300
    #   end
    #
    class MinPpi
      include Preflight::Measurements
      extend  Forwardable

      attr_reader :issues

      # Graphics State Operators
      def_delegators :@state, :save_graphics_state, :restore_graphics_state

      # Matrix Operators
      def_delegators :@state, :concatenate_matrix

      def initialize(min_ppi)
        @min_ppi = min_ppi.to_i
      end

      # we're about to start a new page, reset state
      #
      def page=(page)
        @page   = page
        @state  = PDF::Reader::PageState.new(page)
        @issues = []
      end

      # As each image is drawn on the canvas, determine the amount of device
      # space it's being crammed into and therefore the PPI.
      #
      def invoke_xobject(label)
        @state.invoke_xobject(label) do |xobj|
          case xobj
          when PDF::Reader::FormXObject then
            xobj.walk(self)
          when PDF::Reader::Stream
            invoke_image_xobject(xobj) if xobj.hash[:Subtype] == :Image
          else
            raise xobj.inspect
          end
        end
      end

      private

      def invoke_image_xobject(xobject)
        sample_w = deref(xobject.hash[:Width])  || 0
        sample_h = deref(xobject.hash[:Height]) || 0
        device_w = pt2in(image_width)
        device_h = pt2in(image_height)

        horizontal_ppi = BigDecimal.new((sample_w / device_w).to_s).round(3)
        vertical_ppi   = BigDecimal.new((sample_h / device_h).to_s).round(3)

        if horizontal_ppi < @min_ppi || vertical_ppi < @min_ppi
          top_left     = @state.ctm_transform(0, 1)
          bottom_right = @state.ctm_transform(1, 0)
          @issues << Issue.new("Image with low PPI/DPI", self, :page           => @page.number,
                                                               :horizontal_ppi => horizontal_ppi,
                                                               :vertical_ppi   => vertical_ppi,
                                                               :top            => top_left.first,
                                                               :left           => top_left.last,
                                                               :bottom         => bottom_right.first,
                                                               :right          => bottom_right.last)
        end
      end

      def deref(obj)
        @objects ? @objects.deref(obj) : obj
      end

      # return a height of an image in the current device space. Auto
      # handles the translation from image space to device space.
      #
      def image_height
        bottom_left = @state.ctm_transform(0, 0)
        top_left    = @state.ctm_transform(0, 1)

        Math.hypot(bottom_left.first-top_left.first, bottom_left.last-top_left.last)
      end

      # return a width of an image in the current device space. Auto
      # handles the translation from image space to device space.
      #
      def image_width
        bottom_left  = @state.ctm_transform(0, 0)
        bottom_right = @state.ctm_transform(1, 0)

        Math.hypot(bottom_left.first-bottom_right.first, bottom_left.last-bottom_right.last)
      end

    end
  end
end
