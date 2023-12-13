# frozen_string_literal: true

module Aoc
  # A grid is a two dimensional array of values.  The grid is indexed by
  class Cursor
    include Comparable

    attr_reader :x, :y, :grid

    CARDINAL_DIRECTIONS = %i[up down left right].freeze
    DIRECTIONS = CARDINAL_DIRECTIONS + %i[up_left up_right down_left down_right].freeze

    DELTAS = {
      up: [0, -1],
      down: [0, 1],
      left: [-1, 0],
      right: [1, 0],
      up_left: [-1, -1],
      up_right: [1, -1],
      down_left: [-1, 1],
      down_right: [1, 1]
    }.freeze

    def initialize(grid, x, y)
      @grid = grid
      @x = x
      @y = y
    end

    def <=>(other)
      [@x, @y] <=> if other.is_a?(Cursor)
                     [other.x, other.y]
                   else
                     puts "other is not a cursor #{other.class} - #{other.inspect}"
                     [other[0], other[1]]
                   end
    end

    def eql?(other)
      [@x, @y].eql?([other.x, other.y])
    end

    def hash
      [@x, @y].hash
    end

    def inspect
      [x, y].inspect
    end

    def safe_move(direction, wrap: false)
      raise Aoc::Error, "Invalid direction #{direction}" unless DIRECTIONS.include?(direction)

      dx, dy = DELTAS[direction]
      new_x = x + dx
      new_y = y + dy

      if wrap
        new_x %= @grid.width
        new_y %= @grid.height
      end
      return nil unless @grid.valid?(new_x, new_y)

      Cursor.new(@grid, new_x, new_y)
    end

    def move(direction, wrap: false)
      result = safe_move(direction, wrap:)
      raise Aoc::Error, "Invalid coordinate after cursor #{x},#{y} moving #{direction}" unless result

      result
    end

    def move!(direction, wrap: false)
      raise Aoc::Error, "Invalid direction #{direction}" unless DIRECTIONS.include?(direction)

      dx, dy = DELTAS[direction]
      @x += dx
      @y += dy

      if wrap
        @x %= @grid.width
        @y %= @grid.height
      end
      raise Aoc::Error, "Invalid coordinate after cursor move #{@x},#{@y}" unless @grid.valid?(@x, @y)

      self
    end

    def neighbors(wrap: false)
      restricted_neighbors(DIRECTIONS, wrap:)
    end

    def restricted_neighbors(directions, wrap: false)
      directions.filter_map do |direction|
        safe_move(direction, wrap:)
      end
    end

    def set(value)
      @grid[x, y] = value
    end

    def get
      @grid[x, y]
    end

    def to_s
      value = get

      if !!value == value
        value ? "█" : " "
      else
        value
      end
    end

    def distance(other)
      Math.sqrt(((other.x - x)**2) + ((other.y - y)**2))
    end

    def manhattan_distance(other)
      (other.x - x).abs + (other.y - y).abs
    end
  end
end
