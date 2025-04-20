# frozen_string_literal: true

module HelcimRuby
  class Collection
    include Enumerable

    attr_reader :data, :total

    def self.from_response(response, type:)
      data = response.map { |attrs| type.new(attrs) }
      new(
        data: data,
        total: data.size
      )
    end

    def initialize(data:, total:)
      @data = data
      @total = total
    end

    def each(&block)
      data.each(&block)
    end

    def [](index)
      data[index]
    end

    def first
      data.first
    end

    def last
      data.last
    end

    def empty?
      data.empty?
    end

    def size
      data.size
    end
  end
end
