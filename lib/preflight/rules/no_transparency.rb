# coding: utf-8

require 'forwardable'

module Preflight
  module Rules

    # For some print workflows transparency is forbidden.
    #
    # Arguments: none
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::NoTransparency
    #   end
    #
    class NoTransparency
      include Preflight::Measurements
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
      end

      def invoke_xobject(label)
        @state.invoke_xobject(label) do |xobj|
          case xobj
          when PDF::Reader::FormXObject then
            detect_transparent_form(xobj)
            xobj.walk(self)
          else
            # TODO. can other xobjects have transparency?
          end
        end
      end

      # As each xobject is drawn on the canvas, record if it's Group XObject
      # with transparency
      #
      def detect_transparent_form(form)
        xobject = form.xobject
        group   = deref(xobject.hash[:Group])
        stype   = deref(group[:S])            if group

        if stype == :Transparency
          bbox = xobject.hash[:BBox] || @page.attributes[:MediaBox]
          bbox = translate_to_device_space(bbox)
          @issues << Issue.new("Transparent xobject found", self, :page         => @page.number,
                                                                  :top_left     => bbox[:tl],
                                                                  :bottom_left  => bbox[:bl],
                                                                  :bottom_right => bbox[:br],
                                                                  :top_right    => bbox[:tr])
        end
      end

      private

      def translate_to_device_space(bbox)
        bl_x, bl_y, tr_x, tr_y = *bbox
        {
          :tl => @state.ctm_transform(bl_x, tr_y),
          :bl => @state.ctm_transform(bl_x, bl_y),
          :br => @state.ctm_transform(tr_x, bl_y),
          :tr => @state.ctm_transform(tr_x, tr_y)
        }
      end

      def deref(obj)
        @objects ? @objects.deref(obj) : obj
      end

    end

  end
end
