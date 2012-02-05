# coding: utf-8

module Preflight
  module Rules

    # Check the target PDF doesn't use Filespecs to refer to external files.
    #
    # Arguments: none
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::NoFilespecs
    #   end
    #
    class NoFilespecs

      def check_hash(ohash)
        if count_filespec_dicts(ohash) > 0
          [Issue.new("File uses at least 1 Filespec to refer to an external file", self)]
        else
          []
        end
      end

      private

      def count_filespec_dicts(ohash)
        ohash.select { |key, obj|
          obj.is_a?(::Hash) && (obj[:Type] == :Filespec || obj[:Type] == :F)
        }.size
      end
    end
  end
end
