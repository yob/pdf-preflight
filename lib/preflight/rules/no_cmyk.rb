# coding: utf-8

require 'forwardable'

module Preflight
  module Rules

    # Some print workflows forbid the use of CMYK colour.
    #
    # Arguments: none
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::NoCmyk
    #   end
    #
    class NoCmyk
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

      def set_cmyk_color_for_stroking(c, m, y, k)
        cmyk_detected(c, m, y, k)
      end

      def set_cmyk_color_for_nonstroking(c, m, y, k)
        cmyk_detected(c, m, y, k)
      end

      def set_stroke_color_space(label)
        check_color_space(label)
      end

      def set_nonstroke_color_space(label)
        check_color_space(label)
      end

      private

      def plain_cmyk?(cs)
        cs == :DeviceCMYK || cs == [:DeviceCMYK]
      end

      def indexed_cmyk?(cs)
        cs.is_a?(Array) && cs[0] == :Indexed && cs[1] == :DeviceCMYK
      end

      def alternative_is_cmyk?(cs)
        cs.is_a?(Array) && cs[0] == :Separation && cs[2] == :DeviceCMYK
      end

      def check_color_space(label)
        return if @resource_labels_seen.include?(label)

        cs = @state.find_color_space(label)

        if plain_cmyk?(cs) || indexed_cmyk?(cs) || alternative_is_cmyk?(cs)
          @issues << Issue.new("CMYK color detected", self, :page  => @page.number)
        end

        @resource_labels_seen << label
      end

      def check_xobject(xobject)
        cs = xobject.hash[:ColorSpace]
        if plain_cmyk?(cs) || indexed_cmyk?(cs) || alternative_is_cmyk?(cs)
          @issues << Issue.new("CMYK image detected", self, :page  => @page.number)
        end
      end

      def cmyk_detected(c, m, y, k)
        @issues << Issue.new("CMYK color detected", self, :page    => @page.number,
                                                          :cyan    => c,
                                                          :magenta => m,
                                                          :yellow  => y,
                                                          :k       => k)
      end

      def deref(obj)
        @page.objects.deref(obj)
      end

    end

  end
end
