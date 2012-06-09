# coding: utf-8

require 'forwardable'

module Preflight
  module Rules

    # Some print workflows forbid the use of DeviceN colours (one or
    # more spot colours).
    #
    # Arguments: none
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::NoDevicen
    #   end
    #
    class NoDevicen
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

      def set_stroke_color_space(label)
        check_color_space(label)
      end

      def set_nonstroke_color_space(label)
        check_color_space(label)
      end

      private

      def plain_devicen_names(cs)
        if cs.is_a?(Array) && cs[0] == :DeviceN
          @page.objects.deref(cs[1])
        end
      end

      def indexed_devicen_names(cs)
        if cs.is_a?(Array) && cs[0] == :Indexed
          indexed_base = @page.objects.deref(cs[1])
          if indexed_base.is_a?(Array) && indexed_base[0] == :DeviceN
            @page.objects.deref(indexed_base[1])
          end
        end
      end

      def check_color_space(label)
        return if @resource_labels_seen.include?(label)

        cs           = @state.find_color_space(label)
        spot_names   = plain_devicen_names(cs)
        spot_names ||= indexed_devicen_names(cs)
        if spot_names
          @issues << Issue.new("DeviceN color detected", self, :page => @page.number,
                                                               :names => spot_names)
        end

        @resource_labels_seen << label
      end

      def check_xobject(xobject)
        cs = xobject.hash[:ColorSpace]
        spot_names   = plain_devicen_names(cs)
        spot_names ||= indexed_devicen_names(cs)
        if spot_names
          @issues << Issue.new("DeviceN image detected", self, :page  => @page.number,
                                                               :names => spot_names)
        end
      end

    end

  end
end
