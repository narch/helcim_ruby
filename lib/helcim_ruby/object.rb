require "ostruct"

module HelcimRuby
  class Object < OpenStruct
    def initialize(attributes)
      super(to_ostruct(attributes))
    end

    private

    def to_ostruct(obj)
      case obj
      when Hash
        OpenStruct.new(
          obj.transform_keys { |key| underscore(key.to_s) }
             .transform_values { |val| to_ostruct(val) }
        )
      when Array
        obj.map { |o| to_ostruct(o) }
      else
        obj
      end
    end

    def underscore(string)
      string.gsub(/::/, '/')
            .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr("-", "_")
            .downcase
            .to_sym
    end
  end
end 