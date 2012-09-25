# coding: utf-8

require 'forwardable'
require 'ttfunk'

module Preflight
  module Rules

    # It possible for a PDF producer to request a glyph that isn't in the
    # current font. PDF viewers will typically just ignore the error, but
    # it can be a warning sign of visible problems that some print workflows
    # need to know about.
    #
    # Arguments: none
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::NoMissingGlyphs
    #   end
    #
    class NoMissingGlyphs
      extend  Forwardable

      # Graphics State Operators
      def_delegators :@state, :save_graphics_state, :restore_graphics_state

      # Matrix Operators
      def_delegators :@state, :concatenate_matrix

      # Text State Operators
      def_delegators :@state, :set_text_font_and_size

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

      #####################################################
      # Text Showing Operators
      #####################################################

      def set_text_font_and_size(font_label, size)
        @state.set_text_font_and_size(font_label, size)
        # TODO stop hard coding this object lookup
        @current_font = @page.objects[6]
        @descriptor   = @page.objects.deref(@current_font[:FontDescriptor])
        @font_file    = @page.objects.deref(@descriptor[:FontFile2])
        @ttf = TTFunk::File.new(@font_file.unfiltered_data)
      end

      # record text that is drawn on the page
      def show_text(string) # Tj
        utf8_text = @state.current_font.to_utf8(string)

        utf8_text.unpack("U*").all? { |cp|
          @ttf.cmap.unicode.first[cp] > 0
        }
      end

      def show_text_with_positioning(params) # TJ
        params.each { |arg|
          case arg
          when String
            show_text(arg)
          when Fixnum, Float
            show_text(" ") if arg > 1000
          end
        }
      end

      def move_to_next_line_and_show_text(str) # '
        @state.move_to_start_of_next_line
        show_text(str)
      end

      def set_spacing_next_line_show_text(aw, ac, string) # "
        @state.set_word_spacing(aw)
        @state.set_character_spacing(ac)
        move_to_next_line_and_show_text(string)
      end

    end
  end
end
