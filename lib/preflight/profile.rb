# coding: utf-8


module Preflight

  # base functionality for all profiles.
  #
  module Profile

    def self.included(base) # :nodoc:
      base.class_eval do
        extend  Preflight::Profile::ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
      def profile_name(str)
        @profile_name = str
      end

      def import(profile)
        profile.rules.each do |array|
          rules << array
        end
      end

      def rule(*args)
        rules << args
      end

      def rules
        @rules ||= []
      end

    end

    module InstanceMethods
      def check(input)
        valid_rules?

        if File.file?(input)
          check_filename(input)
        elsif input.is_a?(IO)
          check_io(input)
        else
          raise ArgumentError, "input must be a string with a filename or an IO object"
        end
      end

      def rule(*args)
        instance_rules << args
      end

      private

      def check_filename(filename)
        File.open(filename, "rb") do |file|
          return check_io(file)
        end
      end

      def check_io(io)
        PDF::Reader.open(io) do |reader|
          raise PDF::Reader::EncryptedPDFError if reader.objects.encrypted?
          check_pages(reader) + check_hash(reader)
        end
      rescue PDF::Reader::EncryptedPDFError
        ["Can't preflight an encrypted PDF"]
      end

      def instance_rules
        @instance_rules ||= []
      end

      def all_rules
        self.class.rules + instance_rules
      end

      def check_hash(reader)
        hash_rules.map { |chk|
          chk.check_hash(reader.objects)
        }.flatten.compact
      rescue PDF::Reader::UnsupportedFeatureError
        []
      end

      def check_pages(reader)
        rules_array = page_rules
        issues    = []

        begin
          reader.pages.each do |page|
            page.walk(*rules_array)
            issues += rules_array.map(&:issues).flatten.compact
          end
        rescue PDF::Reader::UnsupportedFeatureError
          nil
        end
        issues
      end

      # ensure all rules follow the prescribed API
      #
      def valid_rules?
        invalid_rules = all_rules.reject { |arr|
          arr.first.instance_methods.map(&:to_sym).include?(:check_hash) ||
            arr.first.instance_methods.map(&:to_sym).include?(:issues)
        }
        if invalid_rules.size > 0
          raise "The following rules are invalid: #{invalid_rules.join(", ")}. Preflight rules MUST respond to either check_hash() or issues()."
        end
      end

      def hash_rules
        all_rules.select { |arr|
          arr.first.instance_methods.map(&:to_sym).include?(:check_hash)
        }.map { |arr|
          klass = arr[0]
          klass.new(*deep_clone(arr[1,10]))
        }
      end

      def page_rules
        all_rules.select { |arr|
          arr.first.instance_methods.map(&:to_sym).include?(:issues)
        }.map { |arr|
          klass = arr[0]
          klass.new(*deep_clone(arr[1,10]))
        }
      end

      # round trip and object through marshall as a hacky but effective
      # way to deep clone the object. Used to ensure rules that mutate
      # their arguments don't impact later profile checks.
      def deep_clone(obj)
        Marshal.load Marshal.dump(obj)
      end
    end
  end
end
