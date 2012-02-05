# coding: utf-8

module Preflight
  module Rules

    # check a file doesn't use unwanted compression algorithms
    #
    # Arguments: a list of permitted compression algorithms.
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::CompressionAlgorithms, :CCITTFaxDecode, :DCTDecode, :FlateDecode
    #   end
    #
    class CompressionAlgorithms

      def initialize(*algorithms)
        @algorithms = algorithms.flatten
      end

      def check_hash(ohash)
        algorithms = banned_algorithms(ohash)

        if algorithms.size > 0
          [Issue.new("File uses excluded compression algorithm", self, :algorithms => algorithms)]
        else
          []
        end
      end

      private

      def banned_algorithms(ohash)
        array = []
        ohash.each do |key, obj|
          if obj.is_a?(PDF::Reader::Stream)
            filters = [obj.hash[:Filter]].flatten.compact
            array += (filters - @algorithms)
          end
        end
        array.uniq
      end
    end
  end
end
