# coding: utf-8

module Preflight
  module Rules

    # Every PDF has a 'Root' dictionary, check that the target file has
    # certain keys in it's Root
    #
    # Arguments: the required keys
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::RootHasKeys, :OutputIntents
    #   end
    #
    class RootHasKeys

      def initialize(*keys)
        @keys = keys.flatten
      end

      def check_hash(ohash)
        root = ohash.object(ohash.trailer[:Root])
        missing = @keys - root.keys
        missing.map { |key|
          Issue.new("Root dict missing required key #{key}", self, :key => key)
        }
      end
    end
  end
end
