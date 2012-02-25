# coding: utf-8

require 'forwardable'

module Preflight
  module Rules

    # Some print workflows forbid the use of Registration Black
    #
    # Arguments: none
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::NoRegistrationBlack
    #   end
    #
    class NoRegistrationBlack
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
          end
        end
      end

      def set_cmyk_color_for_stroking(c, m, y, k)
        reg_black_detected(c, m, y, k) if registration_black?(c, m, y, k)
      end

      def set_cmyk_color_for_nonstroking(c, m, y, k)
        reg_black_detected(c, m, y, k) if registration_black?(c, m, y, k)
      end

      def set_stroke_color_space(label)
        check_color_space(label)
      end

      def set_nonstroke_color_space(label)
        check_color_space(label)
      end

      private

      def registration_black?(c, m, y, k)
        c == 1 && m == 1 && y == 1 && k == 1
      end

      def color_space_is_all?(cs)
        cs.is_a?(Array) && cs[1].to_s.downcase == "all"
      end

      def check_color_space(label)
        return if @resource_labels_seen.include?(label)

        if color_space_is_all?(@state.find_color_space(label))
          @issues << Issue.new("'All' separation color detected", self, :page  => @page.number)
        end

        @resource_labels_seen << label
      end

      def reg_black_detected(c, m, y, k)
        @issues << Issue.new("Registration black detected", self, :page    => @page.number,
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
