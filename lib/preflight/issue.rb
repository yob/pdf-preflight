# encoding: utf-8

module Preflight
  class Issue

    attr_reader :description, :rule, :attributes

    def initialize(description, rule, attributes = {})
      @description = description
      @rule        = rule.to_s.to_sym
      @attributes  = attributes
    end

    def to_s
      @description
    end
  end
end
