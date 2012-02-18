# coding: utf-8

require 'forwardable'
require 'matrix'

module Preflight
  module Rules

    # To print colour to the edge of the page you must print past the intended
    # page edge and then trim the printed sheet. The printed area that will be
    # trimmed is called bleed. Generally you will probably want 3-4mm of bleed.
    #
    # Arguments: the distance from the TrimBox within which objects MUST include bleed
    #            the distance past the TrimBox that objects MUST bleed
    #            the units (:pt, :mm, :in)
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::MinBleed, 1, 4, :mm
    #     rule Preflight::Rules::MinBleed, 12, 50, :pt
    #     rule Preflight::Rules::MinBleed, 0.1, 0.25, :in
    #   end
    #
    class MinBleed
      include Preflight::Measurements
      extend  Forwardable

      attr_reader :issues

      # Graphics State Operators
      def_delegators :@state, :save_graphics_state, :restore_graphics_state

      # Matrix Operators
      def_delegators :@state, :concatenate_matrix

      def initialize(range, bleed, units)
        @range, @bleed, @units = range, bleed, units
      end

      # we're about to start a new page, reset state
      #
      def page=(page)
        @issues  = []
        @page    = page
        @state   = PDF::Reader::PageState.new(page)
        @objects = page.objects

        attrs = @page.attributes
        box   = attrs[:TrimBox] || attrs[:ArtBox] || attrs[:MediaBox]
        @warning_min_x = box[0] + to_points(@range, @units)
        @warning_min_y = box[1] + to_points(@range, @units)
        @warning_max_x = box[2] - to_points(@range, @units)
        @warning_max_y = box[3] - to_points(@range, @units)
        @error_min_x   = box[0] - to_points(@bleed, @units)
        @error_min_y   = box[1] - to_points(@bleed, @units)
        @error_max_x   = box[2] + to_points(@bleed, @units)
        @error_max_y   = box[3] + to_points(@bleed, @units)
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

      def append_rectangle(x1, y1, x2, y2)
        @path ||= []
        @path << @state.ctm_transform(x1, y1)
        @path << @state.ctm_transform(x1, y2)
        @path << @state.ctm_transform(x2, y1)
        @path << @state.ctm_transform(x2, y2)
      end

      def fill_path_with_nonzero
        @path ||= []
        points = select_points_in_danger_zone(@path)

        if points.size > 0
          @issues << Issue.new("Filled object with insufficient bleed", self, :page        => @page.number,
                                                                              :object_type => :filled_object,
                                                                              :bleed       => @bleed,
                                                                              :units       => @units)
        end

        @path = []
      end
      alias :fill_path_with_even_odd :fill_path_with_nonzero

      def close_and_stroke_path
        @path = []
      end

      def stroke_path
        @path = []
      end

      def end_path
        @path = []
      end

      private

      def invoke_image_xobject(xobject)
        return unless @page.attributes[:TrimBox] || @page.attributes[:ArtBox]

        points = select_points_in_danger_zone(image_points)

        if points.size > 0
          @issues << Issue.new("Image with insufficient bleed", self, :page        => @page.number,
                                                                      :object_type => :image,
                                                                      :bleed       => @bleed,
                                                                      :units       => @units)
        end
      end

      def deref(obj)
        @objects ? @objects.deref(obj) : obj
      end

      # convert value units to PDF points. units should be :mm, :in or :pt
      #
      def to_points(value, units)
        case units
        when :mm then mm2pt(value)
        when :in then in2pt(value)
        else
          value
        end
      end

      # return the co-ordinates for the 4 corners of an image according
      # to the current CTM
      #
      def image_points
        [
          @state.ctm_transform(0, 0),
          @state.ctm_transform(0, 1),
          @state.ctm_transform(1, 0),
          @state.ctm_transform(1, 1)
        ]
      end

      # given an array of points, returns the subset of points (if any) that
      # fall within the danger zone indicating they're close to the TrimBox
      # without enough bleed
      #
      def select_points_in_danger_zone(points)
        points.select { |p|
          (p.first < @warning_min_x && p.first > @error_min_x) ||
          (p.last < @warning_min_y  && p.last > @error_min_y) ||
          (p.first > @warning_max_x && p.first < @error_max_x) ||
          (p.last > @warning_max_x  && p.last < @error_max_y)
        }
      end

    end
  end
end
