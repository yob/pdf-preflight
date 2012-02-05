# coding: utf-8

module Preflight
  module Rules

    # All PDFX files MUST have a GTS_PDFX OutputIntent with certain keys
    # GTS_PDFX OutputIntent.
    #
    # This doesn't raise an error if there is no GTS_PDFX, that's another
    # rules job.
    #
    # Arguments: none
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::PdfxOutputIntentHasKeys, :OutputConditionIdentifier, :Info
    #   end
    #
    class PdfxOutputIntentHasKeys

      def initialize(*keys)
        @keys = keys.flatten
      end

      def check_hash(ohash)
        oi = pdfx_output_intent(ohash)

        return [] if oi.nil?

        missing = @keys - oi.keys
        missing.map { |key|
          Issue.new("The GTS_PDFX OutputIntent missing required key #{key}", self, :key => key)
        }
      end

      private

      def pdfx_output_intent(ohash)
        output_intents(ohash).map { |dict|
          ohash.object(dict)
        }.detect { |dict|
          dict[:S] == :GTS_PDFX
        }
      end

      def output_intents(ohash)
        root    = ohash.object(ohash.trailer[:Root])
        intents = ohash.object(root[:OutputIntents])
        intents || []
      end

    end
  end
end
