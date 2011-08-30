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

      attr_reader :messages

      DEFAULT_GRAPHICS_STATE = {
        :ctm => Matrix.identity(3)
      }

      def initialize(min_ppi)
        @min_ppi = min_ppi.to_i
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

        sample_w = deref(xobject(label).hash[:Width])  || 0
        sample_h = deref(xobject(label).hash[:Height]) || 0
        device_w = pt2in(image_width)
        device_h = pt2in(image_height)

        horizontal_ppi = (sample_w / device_w).round(3)
        vertical_ppi   = (sample_h / device_h).round(3)

        if horizontal_ppi < @min_ppi || vertical_ppi < @min_ppi
          @messages << "Image with low PPI/DPI on page #{@page.number} (h:#{horizontal_ppi} v:#{vertical_ppi})"
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

      # return a height of an image in the current device space. Auto
      # handles the translation from image space to device space.
      #
      def image_height
        bottom_left = transform(Point.new(0, 0))
        top_left    = transform(Point.new(0, 1))

        bottom_left.distance(top_left)
      end

      # return a width of an image in the current device space. Auto
      # handles the translation from image space to device space.
      #
      def image_width
        bottom_left  = transform(Point.new(0, 0))
        bottom_right = transform(Point.new(1, 0))

        bottom_left.distance(bottom_right)
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
    # to simplify maths in the MinPpi class.
    #
    class Point
      attr_reader :x, :y

      def initialize(x,y)
        @x, @y = x,y
      end

      def distance(point)
        Math.hypot(point.x - x, point.y - y)
      end
    end
  end
end
