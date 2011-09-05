# coding: utf-8

require 'yaml'
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

      attr_reader :messages

      DEFAULT_GRAPHICS_STATE = {
        :ctm => Matrix.identity(3)
      }

      def initialize(range, bleed, units)
        @range, @bleed, @units = range, bleed, units
      end

      # we're about to start a new page, reset state
      #
      def page=(page)
        @messages = []
        @page    = page
        @objects = page.objects
        @stack   = [DEFAULT_GRAPHICS_STATE]
        @xobjects = @page.xobjects || {}
        @form_xobjects = {}

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

      def save_graphics_state
        @stack.push clone_state
      end

      def restore_graphics_state
        @stack.pop
      end

      # update the current transformation matrix.
      #
      # If the CTM is currently undefined, just store the new values.
      #
      # If there's an existing CTM, then multiple the existing matrix
      # with the new matrix to form the updated matrix.
      #
      def concatenate_matrix(*args)
        transform = Matrix[
          [args[0], args[1], 0],
          [args[2], args[3], 0],
          [args[4], args[5], 1]
        ]
        if state[:ctm]
          state[:ctm] = transform * state[:ctm]
        else
          state[:ctm] = transform
        end
      end

      # As each image is drawn on the canvas, determine the amount of device
      # space it's being crammed into and therefore the PPI.
      #
      def invoke_xobject(label)
        save_graphics_state
        xobject = @objects.deref(xobject(label))

        matrix = xobject.hash[:Matrix]
        concatenate_matrix(*matrix) if matrix

        case xobject.hash[:Subtype]
        when :Form  then invoke_form_xobject(label)
        when :Image then invoke_image_xobject(label)
        else
          # ignore other xobject types for now
        end

        restore_graphics_state
      end

      def append_rectangle(x1, y1, x2, y2)
        @path ||= []
        @path << transform(Point.new(x1, y1))
        @path << transform(Point.new(x1, y2))
        @path << transform(Point.new(x2, y1))
        @path << transform(Point.new(x2, y2))
      end

      def fill_path_with_nonzero
        @path ||= []
        points = select_points_in_danger_zone(@path)

        if points.size > 0
          @messages << "Filled object with insufficient bleed on page #{@page.number} (#{@bleed}#{@units} required)"
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

      def xobject(label)
        deref(@form_xobjects[label] || @xobjects[label])
      end

      def invoke_form_xobject(label)
        return unless xobject(label)
        xobject = @objects.deref(xobject(label))
        form = PDF::Reader::FormXObject.new(@page, xobject)
        @form_xobjects = (form.resources || {})[:XObject] || {}
        form.walk(self)
        @form_xobjects = {}
      end

      def invoke_image_xobject(label)
        return unless xobject(label)
        return unless @page.attributes[:TrimBox] || @page.attributes[:ArtBox]

        points = select_points_in_danger_zone(image_points)

        if points.size > 0
          @messages << "Image with insufficient bleed on page #{@page.number} (#{@bleed}#{@units} required)"
        end
      end

      def deref(obj)
        @objects ? @objects.deref(obj) : obj
      end

      # return the current transformation matrix
      #
      def ctm
        state[:ctm]
      end

      def state
        @stack.last
      end

      # transform x and y co-ordinates from the current user space to the
      # underlying device space.
      #
      def transform(point, z = 1)
        Point.new(
          (ctm[0,0] * point.x) + (ctm[1,0] * point.y) + (ctm[2,0] * z),
          (ctm[0,1] * point.x) + (ctm[1,1] * point.y) + (ctm[2,1] * z)
        )
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
          transform(Point.new(0, 0)),
          transform(Point.new(0, 1)),
          transform(Point.new(1, 0)),
          transform(Point.new(1, 1))
        ]
      end

      # given an array of points, returns the subset of points (if any) that
      # fall within the dnager zone indicating they're close to the TrimBox
      # without enough bleed
      #
      def select_points_in_danger_zone(points)
        points.select { |p|
          (p.x < @warning_min_x && p.x > @error_min_x) ||
          (p.y < @warning_min_y && p.y > @error_min_y) ||
          (p.x > @warning_max_x && p.x < @error_max_x) ||
          (p.y > @warning_max_x && p.y < @error_max_y)
        }
      end

      # when save_graphics_state is called, we need to push a new copy of the
      # current state onto the stack. That way any modifications to the state
      # will be undone once restore_graphics_state is called.
      #
      # This returns a deep clone of the current state, ensuring changes are
      # keep separate from earlier states.
      #
      # YAML is used to round-trip the state through a string to easily perform
      # the deep clone. Kinda hacky, but effective.
      #
      def clone_state
        if @stack.empty?
          {}
        else
          yaml_state = YAML.dump(@stack.last)
          YAML.load(yaml_state)
        end
      end
    end

    # private class for representing points on a cartesian plain. Used
    # to simplify maths in the MinBleed class.
    #
    class Point
      attr_reader :x, :y

      def initialize(x,y)
        @x, @y = x,y
      end

    end
  end
end
