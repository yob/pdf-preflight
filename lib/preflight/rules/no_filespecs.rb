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
        if has_filespecs(ohash)
          ["File uses at least 1 Filespec to refer to an external file"]
        else
          []
        end
      end

      private

      def has_filespecs(ohash)
        ohash.any? { |key, obj|
          obj.is_a?(::Hash) && (obj[:Type] == :Filespec || obj[:Type] == :F) && obj[:EF].nil?
        }
      end
    end
  end
end
