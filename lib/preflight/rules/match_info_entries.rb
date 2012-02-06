# coding: utf-8

module Preflight
  module Rules
    # Every PDF has an optional 'Info' dictionary. Check that the target file
    # has certain keys and that the keys match a given regexp
    #
    # Arguments: the required keys
    #
    # Usage:
    #
    #   class MyPreflight
    #     include Preflight::Profile
    #
    #     rule Preflight::Rules::MatchInfoEntries, {:GTS_PDFXVersion => /\APDF\/X/}
    #   end
    #
    class MatchInfoEntries

      def initialize(matches = {})
        @matches = matches
      end

      def check_hash(ohash)
        array = []
        info = ohash.object(ohash.trailer[:Info])
        @matches.each do |key, regexp|
          if !info.has_key?(key)
            array << Issue.new("Info dict missing required key", self, :key => key)
          elsif !info[key].to_s.match(regexp)
            array << Issue.new("value of Info entry #{key} doesn't match #{regexp}", self, :key    => key,
                                                                                           :regexp => regexp)
          end
        end
        array
      end
    end
  end
end
