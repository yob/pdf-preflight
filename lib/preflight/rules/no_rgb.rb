# coding: utf-8

require 'forwardable'

module Preflight
  module Rules

    # Some print workflows forbid the use of RGB colour.
    #
    # Arguments: none
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::NoRgb
    #   end
    #
    class NoRgb
      extend  Forwardable

      # Graphics State Operators
      def_delegators :@state, :save_graphics_state, :restore_graphics_state

      # Matrix Operators
      def_delegators :@state, :concatenate_matrix

      attr_reader :issues

      # we're about to start a new page, reset state
      #
      def page=(page)
        @page   = page
        @state  = PDF::Reader::PageState.new(page)
        @issues = []
        @resource_labels_seen = []
      end

      # descend into nested form xobjects
      #
      def invoke_xobject(label)
        @state.invoke_xobject(label) do |xobj|
          case xobj
          when PDF::Reader::FormXObject then
            xobj.walk(self)
          when PDF::Reader::Stream then
            check_xobject(xobj)
          end
        end
      end

      def set_rgb_color_for_stroking(r, g, b)
        rgb_detected(r, g, b)
      end

      def set_rgb_color_for_nonstroking(r, g, b)
        rgb_detected(r, g, b)
      end

      def set_stroke_color_space(label)
        check_color_space(label)
      end

      def set_nonstroke_color_space(label)
        check_color_space(label)
      end

      private

      def plain_rgb?(cs)
        cs == :DeviceRGB || cs == [:DeviceRGB]
      end

      def indexed_rgb?(cs)
        cs.is_a?(Array) && cs[0] == :Indexed && cs[1] == :DeviceRGB
      end

      def alternative_is_rgb?(cs)
        cs.is_a?(Array) && cs[0] == :Separation && cs[2] == :DeviceRGB
      end

      def check_color_space(label)
        return if @resource_labels_seen.include?(label)

        cs = @state.find_color_space(label)

        if plain_rgb?(cs) || indexed_rgb?(cs) || alternative_is_rgb?(cs)
          @issues << Issue.new("RGB color detected", self, :page  => @page.number)
        end

        @resource_labels_seen << label
      end

      def check_xobject(xobject)
        cs = xobject.hash[:ColorSpace]
        if plain_rgb?(cs) || indexed_rgb?(cs) || alternative_is_rgb?(cs)
          @issues << Issue.new("RGB image detected", self, :page  => @page.number)
        end
      end

      def rgb_detected(r, g, b)
        @issues << Issue.new("RGB color detected", self, :page  => @page.number,
                                                         :red   => r,
                                                         :green => g,
                                                         :blue  => b)
      end

      def deref(obj)
        @page.objects.deref(obj)
      end

    end

  end
end
