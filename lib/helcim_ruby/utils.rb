# frozen_string_literal: true

module HelcimRuby
  module Utils
    def self.transform_to_camel_case(hash)
      return {} if hash.nil?
      return hash unless hash.is_a?(Hash)

      hash.each_with_object({}) do |(key, value), result|
        camel_key = camelize(key.to_s)
        result[camel_key] = transform_nested_value(value)
      end
    end

    def self.transform_nested_value(value)
      case value
      when Hash then transform_to_camel_case(value)
      when Array then value.map { |item| item.is_a?(Hash) ? transform_to_camel_case(item) : item }
      else value
      end
    end

    def self.camelize(string)
      string.split("_").map.with_index { |word, i| i.zero? ? word : word.capitalize }.join
    end
  end
end
