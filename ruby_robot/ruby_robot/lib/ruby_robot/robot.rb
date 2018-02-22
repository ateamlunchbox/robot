module RubyRobot
class Robot

  # Directions are clockwise from north
  VALID_DIRECTIONS = [:north, :east, :south, :west]

  attr_reader :direction 
  attr_accessor :board
  
  def initialize(direction)
    orig_direction = direction
    err_msg = "New Robots must have direction value of one of the following symbols: #{VALID_DIRECTIONS.join(', ')}; invalid value '#{orig_direction}'"
    direction = direction.kind_of?(String) ? direction.downcase.to_sym : direction
    raise ConstructionError.new(err_msg) unless VALID_DIRECTIONS.include?(direction)
    @direction = direction
    @board = nil
  end

  def inspect
    case @direction
    when :north then "^"
    when :south then "|"
    when :east  then ">"
    # :west
    else "<"
    end
  end

  def left
    # A little cheating here...index -1 will effectively wrap around and
    # return the last element
    @direction = VALID_DIRECTIONS[dir_idx - 1]
  end

  def right
    @direction = VALID_DIRECTIONS[(dir_idx + 1) % VALID_DIRECTIONS.size]
  end

  def dir_idx
    VALID_DIRECTIONS.index(@direction)
  end

end
end