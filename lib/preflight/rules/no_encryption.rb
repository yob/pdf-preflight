# coding: utf-8

module Preflight
  module Rules
    # Check the target PDF isn't encrypted
    #
    # Arguments: none
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::NoEncryption
    #   end
    #
    class NoEncryption

      def check_hash(ohash)
        if ohash.trailer[:Encrypt]
          ["File is encrypted"]
        else
          []
        end
      end
    end
  end
end
