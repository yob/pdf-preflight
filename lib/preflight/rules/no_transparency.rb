# coding: utf-8

require 'yaml'

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

      attr_reader :issues

      # we're about to start a new page, reset state
      #
      def page=(page)
        @issues = []
        @page    = page
        @objects = page.objects
      end

      # As each xobject is drawn on the canvas, record if it's Group XObject
      # with transparency
      #
      def invoke_xobject(label)
        xobj  = deref(@page.xobjects[label])
        group = deref(xobj.hash[:Group])     if xobj
        stype = deref(group[:S])             if group

        if stype == :Transparency
          @issues << Issue.new("Transparent xobject found", self, :page => @page.number)
        end
      end

      private

      def deref(obj)
        @objects ? @objects.deref(obj) : obj
      end

    end

  end
end
