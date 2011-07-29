# coding: utf-8

module Preflight
  module Rules

    # Every PDF has an optional 'Info' dictionary. Check that the target file
    # has certain keys
    #
    # Arguments: the required keys
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::InfoHasKeys, :Title, :CreationDate, :ModDate
    #   end
    #
    class InfoHasKeys

      def initialize(*keys)
        @keys = keys.flatten
      end

      def check_hash(ohash)
        info = ohash.object(ohash.trailer[:Info])
        missing = @keys - info.keys
        missing.map { |key|
          "Info dict missing required key #{key}"
        }
      end
    end
  end
end
