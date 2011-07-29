# coding: utf-8

module Preflight
  module Rules
    # Every PDF has an optional 'Info' dictionary. Check that the dictionary
    # has a 'Trapped' entry that is set to True or False
    #
    # Arguments: none
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::InfoSpecifiesTrapping
    #   end
    #
    class InfoSpecifiesTrapping

      def check_hash(ohash)
        info = ohash.object(ohash.trailer[:Info])

        if !info.has_key?(:Trapped)
          [ "Info dict does not specify Trapped" ]
        elsif info[:Trapped] != :True && info[:Trapped] != :False
          [ "Trapped value of Info dict must be True or False" ]
        else
          []
        end
      end
    end
  end
end
